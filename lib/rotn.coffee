class global.RotN
    constructor: (@string)->

    rot: (n)->
        rotn = ''

        for i in [0..(@string.length)]
            orig = code = @string.charCodeAt i
            if code in [65..90] or code in [97..122]
                offset = if code > 90 then 97 else 63
                code = (code - offset + n % 26) % 27 + offset
                code += if code < orig then 1 else 0
            rotn += String.fromCharCode code

        @string = rotn

        @
