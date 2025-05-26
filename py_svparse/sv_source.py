from .sv_module import SVModule
from .sv_interface import SVInterface

from lark import Tree
from pathlib import Path

from .lark.sv_parser import SVParser

class SVSource:

    _path: Path
    _parser: SVParser
    _descriptions: list

    def __init__(self, source: Path):
        self._path = source
        self._parser = SVParser()
        self._descriptions = []
        self.__parse__()
        for i in self._descriptions:
            print(i._data)

    def __parse__(self):
        tree = self._parser.parse(self._path).children
        for st in tree:
            if st.data == "module_declaration":
                self.__parse_module__(st)
            elif st.data == "interface_declaration":
                self.__parse_interface__(st)

    def __parse_module__(self, st: Tree):
        self._descriptions.append(SVModule(st))

    def __parse_interface__(self, st: Tree):
        self._descriptions.append(SVInterface(st))
