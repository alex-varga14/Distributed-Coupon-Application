# Copyright (c) 2014, 2022, Oracle and/or its affiliates.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2.0, as
# published by the Free Software Foundation.
#
# This program is also distributed with certain software (including
# but not limited to OpenSSL) that is licensed under separate terms,
# as designated in a particular file or component or in included license
# documentation.  The authors of MySQL hereby grant you an
# additional permission to link the program and your derivative works
# with the separately licensed software that they have included with
# MySQL.
#
# Without limiting anything contained in the foregoing, this file,
# which is part of MySQL Connector/Python, is also subject to the
# Universal FOSS Exception, version 1.0, a copy of which can be found at
# http://oss.oracle.com/licenses/universal-foss-exception.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License, version 2.0, for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

# mypy: disable-error-code="assignment,arg-type,override,union-attr"

"""Cursor classes using the C Extension."""
from __future__ import annotations

import re
import warnings
import weakref

from collections import namedtuple
from typing import (
    Any,
    Dict,
    Generator,
    Iterator,
    List,
    NoReturn,
    Optional,
    Sequence,
    Tuple,
    Type,
    Union,
)
from weakref import CallableProxyType

# pylint: disable=import-error,no-name-in-module
from _mysql_connector import MySQLInterfaceError, MySQLPrepStmt

from .types import (
    CextEofPacketType,
    CextResultType,
    DescriptionType,
    ParamsSequenceOrDictType,
    ParamsSequenceType,
    RowType,
    StrOrBytes,
    ToPythonOutputTypes,
    WarningType,
)

# pylint: enable=import-error,no-name-in-module
# isort: split

from .abstracts import NAMED_TUPLE_CACHE, MySQLConnectionAbstract, MySQLCursorAbstract
from .cursor import (
    RE_PY_PARAM,
    RE_SQL_COMMENT,
    RE_SQL_FIND_PARAM,
    RE_SQL_INSERT_STMT,
    RE_SQL_INSERT_VALUES,
    RE_SQL_ON_DUPLICATE,
    RE_SQL_PYTHON_CAPTURE_PARAM_NAME,
    RE_SQL_PYTHON_REPLACE_PARAM,
    RE_SQL_SPLIT_STMTS,
)
from .errorcode import CR_NO_RESULT_SET
from .errors import (
    Error,
    InterfaceError,
    NotSupportedError,
    ProgrammingError,
    get_mysql_exception,
)

ERR_NO_RESULT_TO_FETCH = "No result set to fetch from"


class _ParamSubstitutor:

    """
    Substitutes parameters into SQL statement.
    """

    def __init__(self, params: Sequence[bytes]) -> None:
        self.params: Sequence[bytes] = params
        self.index: int = 0

    def __call__(self, matchobj: object) -> bytes:
        index = self.index
        self.index += 1
        try:
            return self.params[index]
        except IndexError:
            raise ProgrammingError(
                "Not enough parameters for the SQL statement"
            ) from None

    @property
    def remaining(self) -> int:
        """Returns number of parameters remaining to be substituted"""
        return len(self.params) - self.index


class CMySQLCursor(MySQLCursorAbstract):

    """Default cursor for interacting with MySQL using C Extension"""

    _raw: bool = False
    _buffered: bool = False
    _raw_as_string: bool = False

    def __init__(self, connection: Type[MySQLConnectionAbstract]) -> None:
        """Initialize"""
        MySQLCursorAbstract.__init__(self)

        self._affected_rows: int = -1
        self._rowcount: int = -1
        self._nextrow: Tuple[Optional[RowType], Optional[CextEofPacketType]] = (
            None,
            None,
        )

        if not isinstance(connection, MySQLConnectionAbstract):
            raise InterfaceError(errno=2048)
        self._cnx: CallableProxyType[Type[MySQLConnectionAbstract]] = weakref.proxy(
            connection
        )

    def reset(self, free: bool = True) -> None:
        """Reset the cursor

        When free is True (default) the result will be freed.
        """
        self._rowcount = -1
        self._nextrow = None
        self._affected_rows = -1
        self._last_insert_id: int = 0
        self._warning_count: int = 0
        self._warnings: Optional[List[WarningType]] = None
        self._warnings = None
        self._warning_count = 0
        self._description: Optional[List[DescriptionType]] = None
        self._executed_list: List[StrOrBytes] = []
        if free and self._cnx:
            self._cnx.free_result()
        super().reset()

    def _check_executed(self) -> None:
        """Check if the statement has been executed.

        Raises an error if the statement has not been executed.
        """
        if self._executed is None:
            raise InterfaceError(ERR_NO_RESULT_TO_FETCH)

    def _fetch_warnings(self) -> Optional[List[WarningType]]:
        """Fetch warnings

        Fetch warnings doing a SHOW WARNINGS. Can be called after getting
        the result.

        Returns a result set or None when there were no warnings.

        Raises Error (or subclass) on errors.

        Returns list of tuples or None.
        """
        warns = []
        try:
            # force freeing result
            self._cnx.consume_results()
            _ = self._cnx.cmd_query("SHOW WARNINGS")
            warns = self._cnx.get_rows()[0]
            self._cnx.consume_results()
        except MySQLInterfaceError as err:
            raise get_mysql_exception(
                msg=err.msg, errno=err.errno, sqlstate=err.sqlstate
            ) from err
        except Exception as err:
            raise InterfaceError(f"Failed getting warnings; {err}") from None

        if warns:
            return warns

        return None

    def _handle_warnings(self) -> None:
        """Handle possible warnings after all results are consumed.

        Raises:
            Error: Also raises exceptions if raise_on_warnings is set.
        """
        if self._cnx.get_warnings and self._warning_count:
            self._warnings = self._fetch_warnings()

        if not self._warnings:
            return

        err = get_mysql_exception(
            *self._warnings[0][1:3], warning=not self._cnx.raise_on_warnings
        )
        if self._cnx.raise_on_warnings:
            raise err

        warnings.warn(str(err), stacklevel=4)

    def _handle_result(self, result: Union[CextEofPacketType, CextResultType]) -> None:
        """Handles the result after statement execution"""
        if "columns" in result:
            self._description = result["columns"]
            self._rowcount = 0
            self._handle_resultset()
        else:
            self._last_insert_id = result["insert_id"]
            self._warning_count = result["warning_count"]
            self._affected_rows = result["affected_rows"]
            self._rowcount = -1
            self._handle_warnings()

    def _handle_resultset(self) -> None:
        """Handle a result set"""

    def _handle_eof(self) -> None:
        """Handle end of reading the result

        Raises an Error on errors.
        """
        self._warning_count = self._cnx.warning_count
        self._handle_warnings()
        if not self._cnx.more_results:
            self._cnx.free_result()

    def _execute_iter(self) -> Generator[CMySQLCursor, None, None]:
        """Generator returns MySQLCursor objects for multiple statements

        Deprecated: use nextset() method directly.

        This method is only used when multiple statements are executed
        by the execute() method. It uses zip() to make an iterator from the
        given query_iter (result of MySQLConnection.cmd_query_iter()) and
        the list of statements that were executed.
        """
        executed_list = RE_SQL_SPLIT_STMTS.split(self._executed)
        i = 0
        self._executed = executed_list[i]
        yield self

        while True:
            try:
                if not self.nextset():
                    raise StopIteration
            except InterfaceError as err:
                # Result without result set
                if err.errno != CR_NO_RESULT_SET:
                    raise
            except StopIteration:
                return
            i += 1
            try:
                self._executed = executed_list[i].strip()
            except IndexError:
                self._executed = executed_list[0]
            yield self
        return

    def execute(
        self,
        operation: StrOrBytes,
        params: ParamsSequenceOrDictType = (),
        multi: bool = False,
    ) -> Optional[Generator[CMySQLCursor, None, None]]:
        """Execute given statement using given parameters

        Deprecated: The multi argument is not needed and nextset() should
        be used to handle multiple result sets.
        """
        if not operation:
            return None

        try:
            if not self._cnx or self._cnx.is_closed():
                raise ProgrammingError
        except (ProgrammingError, ReferenceError) as err:
            raise ProgrammingError("Cursor is not connected", 2055) from err
        self._cnx.handle_unread_result()

        stmt = ""
        self.reset()

        try:
            if isinstance(operation, str):
                stmt = operation.encode(self._cnx.python_charset)
            else:
                stmt = operation
        except (UnicodeDecodeError, UnicodeEncodeError) as err:
            raise ProgrammingError(str(err)) from err

        if params:
            prepared = self._cnx.prepare_for_mysql(params)
            if isinstance(prepared, dict):
                for key, value in prepared.items():
                    stmt = stmt.replace(f"%({key})s".encode(), value)
            elif isinstance(prepared, (list, tuple)):
                psub = _ParamSubstitutor(prepared)
                stmt = RE_PY_PARAM.sub(psub, stmt)
                if psub.remaining != 0:
                    raise ProgrammingError(
                        "Not all parameters were used in the SQL statement"
                    )

        try:
            result = self._cnx.cmd_query(
                stmt,
                raw=self._raw,
                buffered=self._buffered,
                raw_as_string=self._raw_as_string,
            )
        except MySQLInterfaceError as err:
            raise get_mysql_exception(
                msg=err.msg, errno=err.errno, sqlstate=err.sqlstate
            ) from err

        self._executed = stmt
        self._handle_result(result)

        if multi:
            return self._execute_iter()

        return None

    def _batch_insert(
        self,
        operation: str,
        seq_params: Sequence[ParamsSequenceOrDictType],
    ) -> Optional[bytes]:
        """Implements multi row insert"""

        def remove_comments(match: re.Match) -> str:
            """Remove comments from INSERT statements.

            This function is used while removing comments from INSERT
            statements. If the matched string is a comment not enclosed
            by quotes, it returns an empty string, else the string itself.
            """
            if match.group(1):
                return ""
            return match.group(2)

        tmp = re.sub(
            RE_SQL_ON_DUPLICATE,
            "",
            re.sub(RE_SQL_COMMENT, remove_comments, operation),
        )

        matches = re.search(RE_SQL_INSERT_VALUES, tmp)
        if not matches:
            raise InterfaceError(
                "Failed rewriting statement for multi-row INSERT. Check SQL syntax"
            )
        fmt = matches.group(1).encode(self._cnx.python_charset)
        values = []

        try:
            stmt = operation.encode(self._cnx.python_charset)
            for params in seq_params:
                tmp = fmt
                prepared = self._cnx.prepare_for_mysql(params)
                if isinstance(prepared, dict):
                    for key, value in prepared.items():
                        tmp = tmp.replace(f"%({key})s".encode(), value)
                elif isinstance(prepared, (list, tuple)):
                    psub = _ParamSubstitutor(prepared)
                    tmp = RE_PY_PARAM.sub(psub, tmp)
                    if psub.remaining != 0:
                        raise ProgrammingError(
                            "Not all parameters were used in the SQL statement"
                        )
                values.append(tmp)

            if fmt in stmt:
                stmt = stmt.replace(fmt, b",".join(values), 1)
                self._executed = stmt
                return stmt
            return None
        except (UnicodeDecodeError, UnicodeEncodeError) as err:
            raise ProgrammingError(str(err)) from err
        except Exception as err:
            raise InterfaceError(f"Failed executing the operation; {err}") from None

    def executemany(
        self,
        operation: str,
        seq_params: Sequence[ParamsSequenceOrDictType],
    ) -> Optional[Generator[CMySQLCursor, None, None]]:
        """Execute the given operation multiple times

        The executemany() method will execute the operation iterating
        over the list of parameters in seq_params.

        Example: Inserting 3 new employees and their phone number

        data = [
            ('Jane','555-001'),
            ('Joe', '555-001'),
            ('John', '555-003')
            ]
        stmt = "INSERT INTO employees (name, phone) VALUES ('%s','%s)"
        cursor.executemany(stmt, data)

        INSERT statements are optimized by batching the data, that is
        using the MySQL multiple rows syntax.

        Results are discarded! If they are needed, consider looping over
        data using the execute() method.
        """
        if not operation or not seq_params:
            return None

        try:
            if not self._cnx:
                raise ProgrammingError
        except (ProgrammingError, ReferenceError) as err:
            raise ProgrammingError("Cursor is not connected") from err
        self._cnx.handle_unread_result()

        if not isinstance(seq_params, (list, tuple)):
            raise ProgrammingError("Parameters for query must be list or tuple.")

        # Optimize INSERTs by batching them
        if re.match(RE_SQL_INSERT_STMT, operation):
            if not seq_params:
                self._rowcount = 0
                return None
            stmt = self._batch_insert(operation, seq_params)
            if stmt is not None:
                self._executed = stmt
                return self.execute(stmt)

        rowcnt = 0
        try:
            # When processing read ops (e.g., SELECT), rowcnt is updated
            # based on self._rowcount. For write ops (e.g., INSERT) is
            # updated based on self._affected_rows.
            # The variable self._description is None for write ops, that's
            # why we use it as indicator for updating rowcnt.
            for params in seq_params:
                self.execute(operation, params)
                if self.with_rows and self._cnx.unread_result:
                    self.fetchall()
                rowcnt += self._rowcount if self.description else self._affected_rows
        except (ValueError, TypeError) as err:
            raise InterfaceError(f"Failed executing the operation; {err}") from None

        self._rowcount = rowcnt
        return None

    @property
    def description(self) -> Optional[List[DescriptionType]]:
        """Returns description of columns in a result"""
        return self._description

    @property
    def rowcount(self) -> int:
        """Returns the number of rows produced or affected"""
        if self._rowcount == -1:
            return self._affected_rows
        return self._rowcount

    def close(self) -> bool:
        """Close the cursor

        The result will be freed.
        """
        if not self._cnx:
            return False

        self._cnx.handle_unread_result()
        self._warnings = None
        self._cnx = None
        return True

    def callproc(
        self,
        procname: str,
        args: Sequence[Any] = (),
    ) -> Optional[Union[Dict[str, ToPythonOutputTypes], RowType]]:
        """Calls a stored procedure with the given arguments"""
        if not procname or not isinstance(procname, str):
            raise ValueError("procname must be a string")

        if not isinstance(args, (tuple, list)):
            raise ValueError("args must be a sequence")

        argfmt = "@_{name}_arg{index}"
        self._stored_results = []

        try:
            argnames = []
            argtypes = []

            # MySQL itself does support calling procedures with their full
            # name <database>.<procedure_name>. It's necessary to split
            # by '.' and grab the procedure name from procname.
            procname_abs = procname.split(".")[-1]
            if args:
                argvalues = []
                for idx, arg in enumerate(args):
                    argname = argfmt.format(name=procname_abs, index=idx + 1)
                    argnames.append(argname)
                    if isinstance(arg, tuple):
                        argtypes.append(f" CAST({argname} AS {arg[1]})")
                        argvalues.append(arg[0])
                    else:
                        argtypes.append(argname)
                        argvalues.append(arg)

                placeholders = ",".join(f"{arg}=%s" for arg in argnames)
                self.execute(f"SET {placeholders}", argvalues)

            call = f"CALL {procname}({','.join(argnames)})"

            result = self._cnx.cmd_query(
                call, raw=self._raw, raw_as_string=self._raw_as_string
            )

            results = []
            while self._cnx.result_set_available:
                result = self._cnx.fetch_eof_columns()
                if isinstance(self, (CMySQLCursorDict, CMySQLCursorBufferedDict)):
                    cursor_class = CMySQLCursorBufferedDict
                elif isinstance(
                    self,
                    (CMySQLCursorNamedTuple, CMySQLCursorBufferedNamedTuple),
                ):
                    cursor_class = CMySQLCursorBufferedNamedTuple
                elif self._raw:
                    cursor_class = CMySQLCursorBufferedRaw
                else:
                    cursor_class = CMySQLCursorBuffered
                # pylint: disable=protected-access
                cur = cursor_class(self._cnx.get_self())
                cur._executed = f"(a result of {call})"
                cur._handle_result(result)
                # pylint: enable=protected-access
                results.append(cur)
                self._cnx.next_result()
            self._stored_results = results
            self._handle_eof()

            if argnames:
                self.reset()
                # Create names aliases to be compatible with namedtuples
                args = [
                    f"{name} AS {alias}"
                    for name, alias in zip(
                        argtypes, [arg.lstrip("@_") for arg in argnames]
                    )
                ]
                select = f"SELECT {','.join(args)}"
                self.execute(select)

                return self.fetchone()
            return tuple()

        except Error:
            raise
        except Exception as err:
            raise InterfaceError(f"Failed calling stored routine; {err}") from None

    def nextset(self) -> Optional[bool]:
        """Skip to the next available result set"""
        if not self._cnx.next_result():
            self.reset(free=True)
            return None
        self.reset(free=False)

        if not self._cnx.result_set_available:
            eof = self._cnx.fetch_eof_status()
            self._handle_result(eof)
            raise InterfaceError(errno=CR_NO_RESULT_SET)

        self._handle_result(self._cnx.fetch_eof_columns())
        return True

    def fetchall(self) -> List[RowType]:
        """Return all rows of a query result set.

        Returns:
            list: A list of tuples with all rows of a query result set.
        """
        self._check_executed()
        if not self._cnx.unread_result:
            return []

        rows: Tuple[List[RowType], Optional[CextEofPacketType]] = self._cnx.get_rows()
        if self._nextrow and self._nextrow[0]:
            rows[0].insert(0, self._nextrow[0])

        if not rows[0]:
            self._handle_eof()
            return []

        self._rowcount += len(rows[0])
        self._handle_eof()
        # self._cnx.handle_unread_result()
        return rows[0]

    def fetchmany(self, size: int = 1) -> List[RowType]:
        """Return the next set of rows of a query result set.

        When no more rows are available, it returns an empty list.
        The number of rows returned can be specified using the size argument,
        which defaults to one.

        Returns:
            list: The next set of rows of a query result set.
        """
        self._check_executed()
        if self._nextrow and self._nextrow[0]:
            rows = [self._nextrow[0]]
            size -= 1
        else:
            rows = []

        if size and self._cnx.unread_result:
            rows.extend(self._cnx.get_rows(size)[0])

        if size:
            if self._cnx.unread_result:
                self._nextrow = self._cnx.get_row()
                if (
                    self._nextrow
                    and not self._nextrow[0]
                    and not self._cnx.more_results
                ):
                    self._cnx.free_result()
            else:
                self._nextrow = (None, None)

        if not rows:
            self._handle_eof()
            return []

        self._rowcount += len(rows)
        return rows

    def fetchone(self) -> Optional[RowType]:
        """Return next row of a query result set.

        Returns:
            tuple or None: A row from query result set.
        """
        self._check_executed()
        row = self._nextrow
        if not row and self._cnx.unread_result:
            row = self._cnx.get_row()

        if row and row[0]:
            self._nextrow = self._cnx.get_row()
            if not self._nextrow[0] and not self._cnx.more_results:
                self._cnx.free_result()
        else:
            self._handle_eof()
            return None
        self._rowcount += 1
        return row[0]

    def __iter__(self) -> Iterator[RowType]:
        """Iteration over the result set

        Iteration over the result set which calls self.fetchone()
        and returns the next row.
        """
        return iter(self.fetchone, None)

    def stored_results(self) -> Generator[CMySQLCursor, None, None]:
        """Returns an iterator for stored results

        This method returns an iterator over results which are stored when
        callproc() is called. The iterator will provide MySQLCursorBuffered
        instances.

        Returns a iterator.
        """
        for result in self._stored_results:
            yield result
        self._stored_results = []

    def __next__(self) -> RowType:
        """Iteration over the result set
        Used for iterating over the result set. Calls self.fetchone()
        to get the next row.

        Raises StopIteration when no more rows are available.
        """
        try:
            row = self.fetchone()
        except InterfaceError:
            raise StopIteration from None
        if not row:
            raise StopIteration from None
        return row

    @property
    def column_names(self) -> Tuple[str, ...]:
        """Returns column names

        This property returns the columns names as a tuple.

        Returns a tuple.
        """
        if not self.description:
            return ()
        return tuple(d[0] for d in self.description)

    @property
    def statement(self) -> str:
        """Returns the executed statement

        This property returns the executed statement. When multiple
        statements were executed, the current statement in the iterator
        will be returned.
        """
        try:
            return self._executed.strip().decode("utf8")
        except AttributeError:
            return self._executed.strip()  # type: ignore[return-value]

    @property
    def with_rows(self) -> bool:
        """Returns whether the cursor could have rows returned

        This property returns True when column descriptions are available
        and possibly also rows, which will need to be fetched.

        Returns True or False.
        """
        if self.description:
            return True
        return False

    def __str__(self) -> str:
        fmt = "{class_name}: {stmt}"
        if self._executed:
            try:
                executed = self._executed.decode("utf-8")
            except AttributeError:
                executed = self._executed
            if len(executed) > 40:
                executed = executed[:40] + ".."
        else:
            executed = "(Nothing executed yet)"

        return fmt.format(class_name=self.__class__.__name__, stmt=executed)


class CMySQLCursorBuffered(CMySQLCursor):

    """Cursor using C Extension buffering results"""

    def __init__(self, connection: Type[MySQLConnectionAbstract]):
        """Initialize"""
        super().__init__(connection)

        self._rows: Optional[List[RowType]] = None
        self._next_row: int = 0

    def _handle_resultset(self) -> None:
        """Handle a result set"""
        self._rows = self._cnx.get_rows()[0]
        self._next_row = 0
        self._rowcount: int = len(self._rows)
        self._handle_eof()

    def reset(self, free: bool = True) -> None:
        """Reset the cursor to default"""
        self._rows = None
        self._next_row = 0
        super().reset(free=free)

    def _fetch_row(self) -> Optional[RowType]:
        """Returns the next row in the result set

        Returns a tuple or None.
        """
        row = None
        try:
            row = self._rows[self._next_row]
        except IndexError:
            return None
        else:
            self._next_row += 1

        return row

    def fetchall(self) -> List[RowType]:
        """Return all rows of a query result set.

        Returns:
            list: A list of tuples with all rows of a query result set.
        """
        self._check_executed()
        res = self._rows[self._next_row :]
        self._next_row = len(self._rows)
        return res

    def fetchmany(self, size: int = 1) -> List[RowType]:
        """Return the next set of rows of a query result set.

        When no more rows are available, it returns an empty list.
        The number of rows returned can be specified using the size argument,
        which defaults to one.

        Returns:
            list: The next set of rows of a query result set.
        """
        self._check_executed()
        res = []
        cnt = size or self.arraysize
        while cnt > 0:
            cnt -= 1
            row = self._fetch_row()
            if row:
                res.append(row)
            else:
                break
        return res

    def fetchone(self) -> Optional[RowType]:
        """Return next row of a query result set.

        Returns:
            tuple or None: A row from query result set.
        """
        self._check_executed()
        return self._fetch_row()

    @property
    def with_rows(self) -> bool:
        """Returns whether the cursor could have rows returned

        This property returns True when rows are available,
        which will need to be fetched.

        Returns True or False.
        """
        return self._rows is not None


class CMySQLCursorRaw(CMySQLCursor):
    """Cursor using C Extension return raw results"""

    _raw: bool = True


class CMySQLCursorBufferedRaw(CMySQLCursorBuffered):
    """Cursor using C Extension buffering raw results"""

    _raw: bool = True


class CMySQLCursorDict(CMySQLCursor):
    """Cursor using C Extension returning rows as dictionaries"""

    _raw: bool = False

    def fetchone(self) -> Optional[Dict[str, ToPythonOutputTypes]]:
        """Return next row of a query result set.

        Returns:
            dict or None: A dict from query result set.
        """
        row = super().fetchone()
        return dict(zip(self.column_names, row)) if row else None

    def fetchmany(self, size: int = 1) -> List[Dict[str, ToPythonOutputTypes]]:
        """Return the next set of rows of a query result set.

        When no more rows are available, it returns an empty list.
        The number of rows returned can be specified using the size argument,
        which defaults to one.

        Returns:
            list: The next set of rows of a query result set represented
                  as a list of dictionaries where column names are used as keys.
        """
        res = super().fetchmany(size=size)
        return [dict(zip(self.column_names, row)) for row in res]

    def fetchall(self) -> List[Dict[str, ToPythonOutputTypes]]:
        """Return all rows of a query result set.

        Returns:
            list: A list of dictionaries with all rows of a query
                  result set where column names are used as keys.
        """
        res = super().fetchall()
        return [dict(zip(self.column_names, row)) for row in res]


class CMySQLCursorBufferedDict(CMySQLCursorBuffered):
    """Cursor using C Extension buffering and returning rows as dictionaries"""

    _raw = False

    def _fetch_row(self) -> Optional[Dict[str, ToPythonOutputTypes]]:
        row = super()._fetch_row()
        if row:
            return dict(zip(self.column_names, row))
        return None

    def fetchall(self) -> List[Dict[str, ToPythonOutputTypes]]:
        """Return all rows of a query result set.

        Returns:
            list: A list of tuples with all rows of a query result set.
        """
        res = super().fetchall()
        return [dict(zip(self.column_names, row)) for row in res]


class CMySQLCursorNamedTuple(CMySQLCursor):
    """Cursor using C Extension returning rows as named tuples"""

    named_tuple: Any = None

    def _handle_resultset(self) -> None:
        """Handle a result set"""
        super()._handle_resultset()
        columns = tuple(self.column_names)
        try:
            self.named_tuple = NAMED_TUPLE_CACHE[columns]
        except KeyError:
            self.named_tuple = namedtuple("Row", columns)  # type: ignore[misc]
            NAMED_TUPLE_CACHE[columns] = self.named_tuple

    def fetchone(self) -> Optional[RowType]:
        """Return next row of a query result set.

        Returns:
            tuple or None: A row from query result set.
        """
        row = super().fetchone()
        if row:
            return self.named_tuple(*row)
        return None

    def fetchmany(self, size: int = 1) -> List[RowType]:
        """Return the next set of rows of a query result set.

        When no more rows are available, it returns an empty list.
        The number of rows returned can be specified using the size argument,
        which defaults to one.

        Returns:
            list: The next set of rows of a query result set.
        """
        res = super().fetchmany(size=size)
        if not res:
            return []
        return [self.named_tuple(*res[0])]

    def fetchall(self) -> List[RowType]:
        """Return all rows of a query result set.

        Returns:
            list: A list of tuples with all rows of a query result set.
        """
        res = super().fetchall()
        return [self.named_tuple(*row) for row in res]


class CMySQLCursorBufferedNamedTuple(CMySQLCursorBuffered):
    """Cursor using C Extension buffering and returning rows as named tuples"""

    named_tuple: Any = None

    def _handle_resultset(self) -> None:
        super()._handle_resultset()
        self.named_tuple = namedtuple("Row", self.column_names)  # type: ignore[misc]

    def _fetch_row(self) -> Optional[RowType]:
        row = super()._fetch_row()
        if row:
            return self.named_tuple(*row)
        return None

    def fetchall(self) -> List[RowType]:
        """Return all rows of a query result set.

        Returns:
            list: A list of tuples with all rows of a query result set.
        """
        res = super().fetchall()
        return [self.named_tuple(*row) for row in res]


class CMySQLCursorPrepared(CMySQLCursor):
    """Cursor using MySQL Prepared Statements"""

    def __init__(self, connection: Type[MySQLConnectionAbstract]):
        super().__init__(connection)
        self._rows: Optional[List[RowType]] = None
        self._rowcount: int = 0
        self._next_row: int = 0
        self._binary: bool = True
        self._stmt: Optional[MySQLPrepStmt] = None

    def _handle_eof(self) -> None:
        """Handle EOF packet"""
        self._nextrow = (None, None)
        self._handle_warnings()

    def _fetch_row(self, raw: bool = False) -> Optional[RowType]:
        """Returns the next row in the result set

        Returns a tuple or None.
        """
        if not self._stmt or not self._stmt.have_result_set:
            return None
        row = None

        if self._nextrow == (None, None):
            (row, eof) = self._cnx.get_row(
                binary=self._binary,
                columns=self.description,
                raw=raw,
                prep_stmt=self._stmt,
            )
        else:
            (row, eof) = self._nextrow

        if row:
            self._nextrow = self._cnx.get_row(
                binary=self._binary,
                columns=self.description,
                raw=raw,
                prep_stmt=self._stmt,
            )
            eof = self._nextrow[1]
            if eof is not None:
                self._warning_count = eof["warning_count"]
                self._handle_eof()
            if self._rowcount == -1:
                self._rowcount = 1
            else:
                self._rowcount += 1
        if eof:
            self._warning_count = eof["warning_count"]
            self._handle_eof()

        return row

    def callproc(self, procname: Any, args: Any = None) -> NoReturn:
        """Calls a stored procedue

        Not supported with CMySQLCursorPrepared.
        """
        raise NotSupportedError()

    def close(self) -> None:
        """Close the cursor

        This method will try to deallocate the prepared statement and close
        the cursor.
        """
        if self._stmt:
            self.reset()
            self._cnx.cmd_stmt_close(self._stmt)
            self._stmt = None
        super().close()

    def reset(self, free: bool = True) -> None:
        """Resets the prepared statement."""
        if self._stmt:
            self._cnx.cmd_stmt_reset(self._stmt)
        super().reset(free=free)

    def execute(
        self,
        operation: StrOrBytes,
        params: Optional[ParamsSequenceOrDictType] = None,
        multi: bool = False,
    ) -> None:  # multi is unused
        """Prepare and execute a MySQL Prepared Statement

        This method will prepare the given operation and execute it using
        the given parameters.

        If the cursor instance already had a prepared statement, it is
        first closed.

        Note: argument "multi" is unused.
        """
        if not operation:
            return

        try:
            if not self._cnx or self._cnx.is_closed():
                raise ProgrammingError
        except (ProgrammingError, ReferenceError) as err:
            raise ProgrammingError("Cursor is not connected", 2055) from err

        self._cnx.handle_unread_result(prepared=True)

        charset = self._cnx.charset
        if charset == "utf8mb4":
            charset = "utf8"

        if not isinstance(operation, str):
            try:
                operation = operation.decode(charset)
            except UnicodeDecodeError as err:
                raise ProgrammingError(str(err)) from err

        if isinstance(params, dict):
            replacement_keys = re.findall(RE_SQL_PYTHON_CAPTURE_PARAM_NAME, operation)
            try:
                # Replace params dict with params tuple in correct order.
                params = tuple(params[key] for key in replacement_keys)
            except KeyError as err:
                raise ProgrammingError(
                    "Not all placeholders were found in the parameters dict"
                ) from err
            # Convert %(name)s to ? before sending it to MySQL
            operation = re.sub(RE_SQL_PYTHON_REPLACE_PARAM, "?", operation)

        if operation is not self._executed:
            if self._stmt:
                self._cnx.cmd_stmt_close(self._stmt)
            self._executed = operation

            try:
                operation = operation.encode(charset)
            except UnicodeEncodeError as err:
                raise ProgrammingError(str(err)) from err

            if b"%s" in operation:
                # Convert %s to ? before sending it to MySQL
                operation = re.sub(RE_SQL_FIND_PARAM, b"?", operation)

            try:
                self._stmt = self._cnx.cmd_stmt_prepare(operation)
            except Error:
                self._executed = None
                self._stmt = None
                raise

        self._cnx.cmd_stmt_reset(self._stmt)

        if self._stmt.param_count > 0 and not params:
            return
        if params:
            if not isinstance(params, (tuple, list)):
                raise ProgrammingError(
                    errno=1210,
                    msg=f"Incorrect type of argument: {type(params).__name__}({params})"
                    ", it must be of type tuple or list the argument given to "
                    "the prepared statement",
                )
            if self._stmt.param_count != len(params):
                raise ProgrammingError(
                    errno=1210,
                    msg="Incorrect number of arguments executing prepared statement",
                )

        if params is None:
            params = ()
        res = self._cnx.cmd_stmt_execute(self._stmt, *params)
        if res:
            self._handle_result(res)

    def executemany(
        self, operation: str, seq_params: Sequence[ParamsSequenceType]
    ) -> None:
        """Prepare and execute a MySQL Prepared Statement many times

        This method will prepare the given operation and execute with each
        tuple found the list seq_params.

        If the cursor instance already had a prepared statement, it is
        first closed.
        """
        rowcnt = 0
        try:
            for params in seq_params:
                self.execute(operation, params)
                if self.with_rows:
                    self.fetchall()
                rowcnt += self._rowcount
        except (ValueError, TypeError) as err:
            raise InterfaceError(f"Failed executing the operation; {err}") from err
        self._rowcount = rowcnt

    def fetchone(self) -> Optional[RowType]:
        """Return next row of a query result set.

        Returns:
            tuple or None: A row from query result set.
        """
        self._check_executed()
        return self._fetch_row() or None

    def fetchmany(self, size: Optional[int] = None) -> List[RowType]:
        """Return the next set of rows of a query result set.

        When no more rows are available, it returns an empty list.
        The number of rows returned can be specified using the size argument,
        which defaults to one.

        Returns:
            list: The next set of rows of a query result set.
        """
        self._check_executed()
        res = []
        cnt = size or self.arraysize
        while cnt > 0 and self._stmt.have_result_set:
            cnt -= 1
            row = self._fetch_row()
            if row:
                res.append(row)
        return res

    def fetchall(self) -> List[RowType]:
        """Return all rows of a query result set.

        Returns:
            list: A list of tuples with all rows of a query result set.
        """
        self._check_executed()
        if not self._stmt.have_result_set:
            return []

        rows = self._cnx.get_rows(prep_stmt=self._stmt)
        if self._nextrow and self._nextrow[0]:
            rows[0].insert(0, self._nextrow[0])

        if not rows[0]:
            self._handle_eof()
            return []

        self._rowcount += len(rows[0])
        self._handle_eof()
        return rows[0]


class CMySQLCursorPreparedDict(CMySQLCursorDict, CMySQLCursorPrepared):  # type: ignore[misc]
    """This class is a blend of features from CMySQLCursorDict and CMySQLCursorPrepared

    Multiple inheritance in python is allowed but care must be taken
    when assuming methods resolution. In the case of multiple
    inheritance, a given attribute is first searched in the current
    class if it's not found then it's searched in the parent classes.
    The parent classes are searched in a left-right fashion and each
    class is searched once.
    Based on python's attribute resolution, in this case, attributes
    are searched as follows:
    1. CMySQLCursorPreparedDict (current class)
    2. CMySQLCursorDict (left parent class)
    3. CMySQLCursorPrepared (right parent class)
    4. CMySQLCursor (base class)
    """
