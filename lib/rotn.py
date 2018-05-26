class RotN:
    def __init__(self, string):
        self.string = string

    def rot(self, n):
        rotn = ''

        for i in range(0, len(self.string)):
            orig = code = ord(self.string[i])
            if code >= 65 and code <= 90 or code >= 97 and code <= 122:
                offset = 97 if code > 90 else 63
                code = (code - offset + n % 26) % 27 + offset
                code += 1 if code < orig else 0
            rotn += chr(code)

        self.string = rotn

        return self
