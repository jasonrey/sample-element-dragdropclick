$ ->
    $body = $ "body"

    dropsFrame = $ ".drops"
    choicesFrame = $ ".choices"

    drops = $ ".drop"
    choices = $ ".choice"

    choices.on "click", (event) ->
        # Because parent has click event of its own, we do not want choices click to propagate up
        event.stopPropagation()

        choice = $ @
        choiceParent = choice.parent()

        choicesFrame.removeClass "receiving"
        drops.removeClass "receiving"

        if choice.hasClass "active"
            choice.removeClass "active"
        else
            choices.removeClass "active"
            choice.addClass "active"
            drops.not(choiceParent).addClass "receiving"

            if choiceParent.hasClass "drop"
                choicesFrame.addClass "receiving"

    $body.on "click", ".receiving", (event) ->
        frame = $ @
        activeChoice = choices.filter ".active"

        return if activeChoice.length is 0

        activeChoice.trigger "dropping"
        frame.trigger "receiving", [activeChoice]

    choices.on "dropping", ->
        choice = $ @

        choice.removeClass "active"

        choicesFrame.removeClass "receiving"
        drops.removeClass "receiving"

    dropsFrame.on "receiving", ".drop", (event, choice) ->
        frame = $ @

        childChoice = frame.find ".choice"

        choiceParent = choice.parent()

        if choiceParent.hasClass "drop"
            choiceParent.append childChoice
        else
            choicesFrame.trigger "receiving", [childChoice]

        frame.append choice

    choicesFrame.on "receiving", (event, choice) ->
        frame = $ @

        frame.append choice

        frame
            .find ".choice"
            .sort (a, b) ->
                x = $(a).data "order"
                y = $(b).data "order"

                return if x < y then -1 else 1
            .detach()
            .appendTo frame

    choices.on "mouseover", (event) ->
        event.stopPropagation()

    choicesFrame.on "mouseover", ->
        frame = $ @
        frame.addClass "hover"

    choicesFrame.on "mouseout", ->
        frame = $ @
        frame.removeClass "hover"