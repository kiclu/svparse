
from pathlib import Path
from lark import Lark, Tree

class SVParser:

    _parser: Lark = None
    _tree: Tree

    def __init__(self):
        if self._parser is None:
            self._parser = Lark(self.__load_grammar__(), start='description')

    def __load_grammar__(self):
        try:
            with open("sv_grammar.lark", "r") as f:
                return f.read()
        except Exception as e:
            raise e
        
    def __load_source__(self, source: Path) -> str:
        try:
            with open(source, "r") as f:
                return f.read()
        except Exception as e:
            raise e

    def parse(self, source: Path) -> Tree:
        self._tree = self._parser.parse(self.__load_source__(source))
        return self._tree
