import nox
python_versions = ['2.7', '3.5', '3.7']

@nox.parametrize("install_cmd", [
    ('pip', 'install', '.'),
    ('pip', 'install', '-e', '.'),
    ('python', 'setup.py', 'install'),
    ('python', 'setup.py', 'develop')
])
@nox.session(python=python_versions)
def test_import(session, install_cmd):
    """
        Test that can import under all supported python versions
        and with all supported installation methods
    """
    session.run(*install_cmd)
    session.run('python', '-c', 'from testml.bridge import TestMLBridge')

@nox.session(python=python_versions)
def test_import(session):
    """
        Test that unit tests are passing under all supported python versions
    """
    session.run('make', 'test')

