# Generated by Django 4.1.7 on 2023-03-09 04:02

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('backendcore', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Coupon',
            fields=[
                ('couponID', models.IntegerField(primary_key=True, serialize=False)),
                ('vendorID', models.IntegerField()),
                ('expiryDate', models.DateField()),
                ('title', models.CharField(max_length=50)),
                ('description', models.TextField(max_length=150)),
                ('quantity', models.IntegerField()),
                ('isMultiuse', models.BooleanField(default=False)),
            ],
        ),
        migrations.CreateModel(
            name='Vendor',
            fields=[
                ('id', models.IntegerField(primary_key=True, serialize=False)),
                ('country', models.CharField(max_length=20)),
                ('city', models.CharField(max_length=20)),
                ('vendorName', models.CharField(max_length=20)),
            ],
        ),
    ]
