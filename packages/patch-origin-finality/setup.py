from setuptools import setup, find_packages

setup(
    name='patch-origin-finality',
    version='0.14',
    packages=find_packages(),
    install_requires=[
        'pycdlib',
    ],
    entry_points={
        'console_scripts': [
            'patch-origin-finality=patch_origin_finality.main:main',
        ],
    },
)
