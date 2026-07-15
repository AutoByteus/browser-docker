# Implementation

- Added `supervisor==4.3.0` to the Python 3.13 pip installation.
- Updated `/entrypoint.sh` to execute `/usr/local/bin/supervisord`, ensuring the pip-installed compatible release is used instead of Ubuntu's `/usr/bin/supervisord` 4.2.1.
- Bumped the base image version to `1.3.8` and updated the feature documentation.
