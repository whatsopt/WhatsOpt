#!/usr/bin/env python

from distutils.core import setup

setup(
    name="whatsopt_server",
    version="0.1.0",
    description="WhatsOpt services implemented with Apache Thrift",
    author="Rémi Lafage",
    author_email="remi.lafage@onera.fr",
    url="https://github.com/OneraHub/WhatsOpt",
    packages=["whatsopt_server"],
    entry_points="""
        [console_scripts]
        whatsopt_server=whatsopt.__main__:main
    """,
)

