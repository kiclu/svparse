from .sv_declaration import SVDeclaration

import pyslang

class SVInterface(SVDeclaration):

    def __init__(self):
        super.__init__()

    def parse(self, node: pyslang.ModuleDeclarationSyntax):
        pass