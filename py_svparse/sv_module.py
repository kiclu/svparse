from .sv_declaration import SVDeclaration

import pyslang

class SVModule(SVDeclaration):

    def __init__(self, node: pyslang.ModuleDeclarationSyntax = None):
        super().__init__()
        self._header = None
        self._parameters = None
        self._ports = None
        if node is not None:
            self.parse(node)

    def parse(self, node: pyslang.ModuleDeclarationSyntax):
        self._header = node.header
        self.__parse_header__(self._header)

    def __parse_header__(self, node: pyslang.ModuleHeaderSyntax):
        self._name = node.name.rawText
        self._imports = node.imports
        self._parameters = self.__parse_parameters__(node.parameters)
        self._ports = self.__parse_ports__(node.ports)