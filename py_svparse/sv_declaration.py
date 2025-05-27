import pyslang

class SVDeclaration:

    _name: str
    _header: pyslang.ModuleHeaderSyntax
    _imports: set

    def __init__(self):
        self._name = None

    def parse(self):
        pass

    def __parse_parameters__(self, params: pyslang.ParameterPortListSyntax):
        for paramlist in params:
            if type(paramlist) is pyslang.SyntaxNode:
                for param in paramlist:
                    self.__parse_parameter__(param)

    def __parse_parameter__(self, param):
        # pyslang.ParameterDeclarationSyntax
        if type(param) is pyslang.Token: return
        print(type(param))

    def __parse_ports__(self, ports: pyslang.PortListSyntax):
        for portlist in ports:
            if type(portlist) is pyslang.SyntaxNode:
                for port in portlist:
                    self.__parse_port__(port)

    def __parse_port__(self, port):
        # pyslang.ImplicitAnsiPortSyntax
        if type(port) is pyslang.Token: return
        print(type(port))
