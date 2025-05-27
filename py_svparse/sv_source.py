from .sv_declaration import SVDeclaration
from .sv_module import SVModule
from .sv_interface import SVInterface

from pathlib import Path

import pyslang

class SVSource:

    _source: Path
    _tree: pyslang.SyntaxTree
    _members: list[SVDeclaration]

    def __init__(self, source: Path):
        self._source = source
        self._tree = pyslang.SyntaxTree.fromFile(self._source)
        self._members = []
        self.__parse__()

    def __parse__(self):
        for i in self._tree.root.members:
            if type(i) is pyslang.ModuleDeclarationSyntax:
                self.__parse_module_declaration_syntax__(i)
            elif type(i) is pyslang.ClassDeclarationSyntax:
                print("class")
            else:
                raise Exception("Unsupported SyntaxNode type")

    def __parse_module_declaration_syntax__(self, node: pyslang.ModuleDeclarationSyntax):
        if node.kind == pyslang.SyntaxKind.ModuleDeclaration:
            print("module %s" % node.header.name)
            self._members.append(SVModule(node))
        elif node.kind == pyslang.SyntaxKind.InterfaceDeclaration:
            print("interface %s" % node.header.name)
        elif node.kind == pyslang.SyntaxKind.PackageDeclaration:
            print("package %s" % node.header.name)
        else:
            raise Exception("Unsupported ModuleDeclarationSyntax kind")
