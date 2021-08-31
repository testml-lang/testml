# XXX Convert from yaml

import pytest

def pytest_collect_file(parent, path):
    if path.ext == ".tml" and path.basename.startswith("test"):
        return TestMLFile.from_parent(parent, fspath=path)

class TestMLFile(pytest.File):
    def collect(self):
        import testml.run.pytest

        raw = yaml.safe_load(self.fspath.open())
        for name, spec in sorted(raw.items()):
            yield TestMLItem.from_parent(self, name=name, spec=spec)

class TestMLItem(pytest.Item):
    def __init__(self, name, parent, spec):
        super().__init__(name, parent)
        self.spec = spec

    def runtest(self):
        for name, value in sorted(self.spec.items()):
            # Some custom test execution (dumb example follows).
            if name != value:
                raise TestMLException(self, name, value)

    def repr_failure(self, excinfo):
        """Called when self.runtest() raises an exception."""
        if isinstance(excinfo.value, TestMLException):
            return "\n".join(
                [
                    "usecase execution failed",
                    "   spec failed: {1!r}: {2!r}".format(*excinfo.value.args),
                    "   no further details known at this point.",
                ]
            )

    def reportinfo(self):
        return self.fspath, 0, f"usecase: {self.name}"

class TestMLException(Exception):
    """Custom exception for error reporting."""
