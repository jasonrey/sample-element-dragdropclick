$ ->
    $body = $ "body"

    dropsFrame = $ ".drops"
    choicesFrame = $ ".choices"

    choices = $ ".choice"
    drops = $ ".drop"

    # choices.draggable(
    #     revert: "invalid"
    # )
    # drops.droppable()
    # choicesFrame.droppable()

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

    $body.on "dropping", ".choice", ->
        choice = $ @

        choice.removeClass "active"

        choicesFrame.removeClass "receiving"
        drops.removeClass "receiving"

    dropsFrame.on "receiving", ".drop", (event, choice) ->
        frame = $ @

        childChoice = frame.find ".choice"

        choiceParent = choice.parent()

        # If the drop frame already have a child, then we need to switch
        if childChoice.length > 0
            if choiceParent.hasClass "drop"
                # Coming from other drop
                choiceParent.append childChoice
            else
                # Coming from choice
                choicesFrame.trigger "receiving", [childChoice]

                order = childChoice.data "order"

                choicesFrame
                    .find ".choice.psuedo[data-order=" + order + "]"
                    .remove()

        # If the choice is coming from choices, then we need to create a psuedo choice
        if choiceParent.hasClass "choices"
            psuedoChoice = choice.clone()
            psuedoChoice.addClass "psuedo"

            choicesFrame.trigger "receiving", [psuedoChoice]

        frame.append choice

    choicesFrame.on "receiving", (event, choice) ->
        frame = $ @

        frame.append choice

        # Remove the psuedo choice if the appending choice is not a psuedo
        if !choice.hasClass "psuedo"
            order = choice.data "order"

            frame
                .find ".choice.psuedo[data-order=" + order + "]"
                .remove()

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

    drops.on "mouseover", ->
        drop = $ @
        drop.addClass "hover"

    drops.on "mouseout", ->
        drop = $ @
        drop.removeClass "hover"