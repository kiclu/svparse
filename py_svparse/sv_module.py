from lark import Tree, Token

from .sv_declaration import SVDeclaration

class SVModule(SVDeclaration):

    def __init__(self, tree: Tree):
        super().__init__(tree)

    def module_declaration(self, tree: Tree):
        return None
    
    def module_nonansi_header(self, _):
        pass

    def module_ansi_header(self, _):
        pass