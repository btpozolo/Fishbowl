import Foundation

// MARK: - Sample Words for Testing
extension GameState {
    func addSampleWords() {
        let allSampleWords = [
            "accordion", "alien", "avalanche", "bacon", "ballerina", "banjo", "barnacle", "beard", "beehive", "bicycle",
            "bingo", "blender", "blobfish", "boomerang", "broomstick", "bubble", "bulldozer", "burrito", "cactus", "cannonball",
            "carnival", "caterpillar", "cheeseburger", "cheetah", "chimney", "clown", "coconut", "compass", "cookie", "cowboy",
            "crayon", "crowbar", "cupcake", "dinosaur", "doughnut", "dracula", "dragon", "drill", "drone", "duckling",
            "earmuffs", "eclipse", "eel", "elbow", "emu", "fairy", "falcon", "fireplace", "flamingo", "flippers",
            "fridge", "funnel", "gargoyle", "gazebo", "giraffe", "goblin", "goggles", "grapefruit", "grenade", "guillotine",
            "gumdrop", "hamster", "hammock", "hang glider", "helicopter", "hippopotamus", "hobo", "hotdog", "hoverboard", "hula hoop",
            "iceberg", "igloo", "invisible ink", "jellyfish", "jigsaw", "joystick", "jukebox", "kangaroo", "kazoo", "ketchup",
            "kite", "knight", "koala", "ladle", "lampshade", "lantern", "lava", "leprechaun", "limousine", "lizard",
            "lobster", "magnet", "mango", "manatee", "marshmallow", "mermaid", "meteor", "microscope", "mime", "moose",
            "mop", "mushroom", "narwhal", "nightlight", "ninja", "noodle", "octopus", "omelet", "ostrich", "otter",
            "pail", "panther", "parrot", "peacock", "penguin", "piñata", "pirate", "platypus", "plunger", "popcorn",
            "porcupine", "pretzel", "pyramid", "quicksand", "quokka", "raccoon", "rainbow", "raspberry", "rhinoceros", "rollercoaster",
            "sandcastle", "sasquatch", "scarecrow", "scarf", "shark", "shopping cart", "slingshot", "snail", "snowball", "spaceship",
            "spatula", "sphinx", "squid", "squirrel", "stapler", "suitcase", "swamp", "swan", "taco", "tarantula",
            "teacup", "telescope", "thermometer", "thumbtack", "toaster", "toilet", "tomato", "trampoline", "trombone", "trophy",
            "turtle", "unicorn", "vacuum", "vampire", "volcano", "waffle", "wagon", "walrus", "werewolf", "whale",
            "wig", "windmill", "wizard", "xylophone", "yeti", "yo-yo", "zebra", "zeppelin", "zombie"
        ]
        
        let shuffledWords = allSampleWords.shuffled()
        let selectedWords = Array(shuffledWords.prefix(30))
        
        for word in selectedWords {
            addWord(word)
        }
    }
} 
