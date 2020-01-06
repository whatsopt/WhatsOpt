#!/usr/bin/env python

from distutils.core import setup

setup(
    name="whatsopt_surrogate_server",
    version="0.1.0",
    description="WhatsOpt Surrogate Server implemented with Apache Thrift",
    author="Rémi Lafage",
    author_email="remi.lafage@onera.fr",
    url="https://github.com/OneraHub/WhatsOpt",
    packages=["whatsopt_services"],
    entry_points="""
        [console_scripts]
        whatsopt_surrogate_server=whatsopt_services.__main__:main
    """,
)

