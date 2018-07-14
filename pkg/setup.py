#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""\
Packaging for PyPI TestML
"""

from setuptools import setup, find_packages
from os import path

# io.open is needed to support Python 2.7
from io import open

here = path.abspath(path.dirname(__file__))

# Get the long description from the README file
with open(path.join(here, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

setup(
    name='testml',
    version='0.0.1',
    description='TestML framework for Python',
    long_description=long_description,
    long_description_content_type='text/markdown',
    url='https://testml.org',
    author='Ingy döt Net',
    author_email='ingy@ingy.net',
    license='MIT',
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Developers',
        'Topic :: Software Development :: Testing',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        # 'Programming Language :: Python :: 3',
        # 'Programming Language :: Python :: 3.4',
        # 'Programming Language :: Python :: 3.5',
        # 'Programming Language :: Python :: 3.6',
        # 'Programming Language :: Python :: 3.7',
    ],
    keywords='test testing development',
    packages=find_packages(exclude=['Makefile']),
    install_requires=[],
    extras_require={
        'dev': [],
        'test': [],
    },
    package_data={
        'testml': ['tests/*'],
    },
    project_urls={
        'Bug Reports': 'https://github.com/testml-lang/testml/issues/',
        'Source': 'https://github.com/testml-lang/testml/',
    },
)
