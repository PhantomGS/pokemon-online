import QtQuick 1.0
import pokemononline.battlemanager.proxies 1.0
import "colors.js" as Colors

Item {
    id: woof
    property bool back: false
    property FieldPokeData fieldPokemon
    property PokeData pokemon


    function isKoed() {
        return pokemon.status === 31 || pokemon.numRef === 0;
    }

    PokeballAnimation {
        id: pokeball;
        paused: true;
        opacity: 1;
    }

    width: 96
    height: 96

    ProgressBar {
        parent: woof.parent
        x: woof.x
        y: woof.y - 15;
    }

    Image {
        id: image
        transformOrigin: Item.Bottom
        source: "image://pokeinfo/pokemon/"+pokemon.numRef+"&back="+back+"&shiny="+pokemon.shiny

        onSourceChanged: shader.grab();
    }

    /* Used to display fainted pokemon */
    ColorShader {
        id: shader
        image: image
        blendColor: Colors.statusColor(pokemon.status)
        alpha: (pokemon.status === PokeData.Fine || pokemon.status == PokeData.Koed) ? 0.0 : 0.3
    }

    states: [
        State {
            name: "koed"
            when: isKoed()
            PropertyChanges {
                target: image
                opacity: 0;
            }
        },

        State {
            name: "onTheField"
            when: fieldPokemon.onTheField
            PropertyChanges {
                target: image
                opacity: 1;
                scale: 1;
            }
        },

        State {
            name: "offTheField"
            when: !fieldPokemon.onTheField
            PropertyChanges {
                target: image
                opacity: 0;
            }
        }
    ]

    transitions: [
        Transition {
            from: "onTheField"
            to: "koed"
            SequentialAnimation {
                running: woof.pokemon.numRef !== 0
                ScriptAction {script: {
                        //battle.scene.debug("Beginning ko animation for " + woof.pokemon.numRef + "\n");
                        battle.scene.pause();}}
                ParallelAnimation {
                    NumberAnimation {
                        target: image; property: "opacity";
                        from: 1; to: 0; duration: 800
                    }
                    NumberAnimation {
                        target: image; property: "y";
                        from: image.y; to: image.y+96; duration: 800;
                    }
                }
                /* Restores image state */
                ScriptAction {script: {image.y -= 96;
                        //battle.scene.debug("Ending ko animation for " + woof.pokemon.numRef + "\n");
                        battle.scene.unpause();}}
            }
        },
        Transition {
            from: "*"
            to: "onTheField"
            SequentialAnimation {
                ScriptAction { script: {
                        //battle.scene.debug("Beginning sendout animation for " + woof.pokemon.numRef + "\n");
                        battle.scene.pause(); image.opacity = shader.opacity=0;
                        pokeball.opacity=1; pokeball.trigger(); } }
                PauseAnimation { duration: 1000 }
                ScriptAction {script: {shader.opacity = image.opacity = 1; image.y -= 70;}}
                NumberAnimation { target:image; from: 0.5;
                    to: 1.0; property: "scale"; duration: 350; easing.type: Easing.InQuad }
                PauseAnimation { duration: 150 }
                NumberAnimation { target:image; from: image.y-70;
                    to: image.y; property: "y"; duration: 400; easing.type: Easing.OutBounce}
                /* Grace pausing time after a pokemon is sent out*/
                NumberAnimation {duration: 300}
                ScriptAction {script: {
                        //battle.scene.debug("Ending  sendout animation for " + woof.pokemon.numRef + "\n");
                        battle.scene.unpause();
                    }
                }
            }
        },
        Transition {
            from: "onTheField"
            to: "offTheField"
            SequentialAnimation {
                ScriptAction {script: {
                        //battle.scene.debug("Beginning sendback animation for " + woof.pokemon.numRef + "\n");
                        battle.scene.pause();}}
                NumberAnimation { target: image; property: "scale";
                    duration:400; from: 1.0; to: 0.5 ; easing.type: Easing.InQuad }
                NumberAnimation { property: "opacity";  duration: 200
                    from: 1.0; to: 0; target: image}
                ScriptAction {script: {image.scale = 1;
                        //battle.scene.debug("Ending sendback animation for " + woof.pokemon.numRef + "\n");
                        battle.scene.unpause();}}
            }
        }
    ]
}
