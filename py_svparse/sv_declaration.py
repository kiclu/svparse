from lark import Tree
from lark.visitors import Transformer

class SVDeclaration(Transformer):

    _name: str
    _data: dict

    def __init__(self, tree: Tree):
        super().__init__()
        self._name = None
        self._data = self.transform(tree)