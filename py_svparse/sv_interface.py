
from lark import Tree
from .sv_declaration import SVDeclaration


class SVInterface(SVDeclaration):

    def __init__(self, tree: Tree):
        super.__init__(tree)

    def interface_declaration(self, _):
        return None