$ ->
    master =
        "1":
            "1": 2
            "2": 4
            "3": 3
            "4": 1

    checkAnswer = (data) ->
        dfd = $.Deferred()

        answer = master[data.id]

        response =
            state: true
            answers: {}

        for dropid, choiceid of answer
            a = state: true

            if choiceid isnt data.answers[dropid]
                response.state = false
                a.state = false
                a.choiceid = choiceid

            response.answers[dropid] = a

        dfd.resolve response

        return dfd

    items = $ "[data-type='drop']"

    return if items.length is 0

    for item in items
        item = $ item

        dropsFrame = item.find ".question"
        choicesFrame = item.find ".choices"

        choices = choicesFrame.find ".choice"
        drops = dropsFrame.find ".drop"

        # Bind directly on choices because we do not want the click to propagate
        choices.on "click", (event) ->
            # Because parent has click event of its own, we do not want choices click to propagate up
            event.stopPropagation()

            return if item.data "locked"

            choice = $ @
            choiceParent = choice.parent()

            choicesFrame.removeClass "receiving"
            drops.removeClass "receiving"

            if choice.hasClass "selected"
                choice.removeClass "selected"
            else
                choices.removeClass "selected"
                choice.addClass "selected"
                drops.not(choiceParent).addClass "receiving"

                if choiceParent.hasClass "drop"
                    choicesFrame.addClass "receiving"

        item.on "click", ".receiving", (event) ->
            frame = $ @
            activeChoice = choices.filter ".selected"

            return if activeChoice.length is 0

            activeChoice.trigger "dropping"
            frame.trigger "receiving", [activeChoice]

        item.on "dropping", ".choice", ->
            choice = $ @

            choice.removeClass "selected"

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
            return if item.data "locked"

            frame = $ @
            frame.addClass "hover"

        choicesFrame.on "mouseout", ->
            frame = $ @
            frame.removeClass "hover"

        drops.on "mouseover", ->
            return if item.data "locked"

            drop = $ @
            drop.addClass "hover"

        drops.on "mouseout", ->
            drop = $ @
            drop.removeClass "hover"

        item.on "click", ".check", (event) ->
            block = $ event.delegateTarget

            return if block.data "locked"

            block.data "locked", true

            id = block.data "id"

            answers = {}

            for drop in drops
                drop = $ drop
                dropid = drop.data "dropid"
                choice = drop.find ".choice"
                choiceid = choice.data "choiceid"

                answers[dropid] = choiceid

            checkAnswer(
                id: id
                answers: answers
            ).done (response) ->
                # response.state (boolean)
                # response.answers (optional)

                if response.state
                    drops.addClass "correct"
                else
                    for dropid, a of response.answers
                        drops
                            .filter "[data-dropid=" + dropid + "]"
                            .addClass if a.state then "correct" else "wrong"