# Generated by Django 4.1.7 on 2023-03-09 04:05

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('backendcore', '0002_coupon_vendor'),
    ]

    operations = [
        migrations.AlterField(
            model_name='coupon',
            name='expiryDate',
            field=models.CharField(max_length=25),
        ),
    ]
