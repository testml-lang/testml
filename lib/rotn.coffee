class global.RotN
    constructor: (@string)->

    rot: (n)->
        rotn = ''

        for i in [0...(@string.length)]
            orig = code = @string.charCodeAt i
            if code in [65..90] or code in [97..122]
                offset = if code >= 97 then 97 else 65
                code = (code - offset + n % 26) % 26 + offset
            rotn += String.fromCharCode code

        @string = rotn

        @
