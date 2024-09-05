//
//  ProfilePicturePicker.swift
//  CraftPortal
//
//  Created by Larry Zeng on 9/5/24.
//

import SwiftUI

struct ProfilePicturePicker: View {
    @Binding var currentProfileName: String

    let columns = [
        GridItem(.fixed(68)),
        GridItem(.fixed(68)),
        GridItem(.fixed(68)),
        GridItem(.fixed(68)),
        GridItem(.fixed(68)),
        GridItem(.fixed(68)),
        GridItem(.fixed(68)),
        GridItem(.fixed(68)),
        GridItem(.fixed(68)),
        GridItem(.fixed(68)),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(ProfilePicturePicker.profiles, id: \.self) {
                    profileName in

                    Image(profileName)
                        .resizable()
                        .frame(width: 64, height: 64)
                        .border(
                            profileName == currentProfileName ? .gray : .clear
                        )
                        .hoverCursor()
                        .onTapGesture {
                            currentProfileName = profileName
                        }
                }
            }
        }
        .padding()
    }
}

extension ProfilePicturePicker {
    static let profiles = [
        "Bedrock",
        "Bookshelf",
        "Brick",
        "Cake",
        "Carved_Pumpkin",
        "Chest",
        "Clay",
        "Coal_Block",
        "Coal_Ore",
        "Cobblestone",
        "Crafting_Table",
        "Creeper_Head",
        "default",
        "Diamond_Block",
        "Diamond_Ore",
        "Dirt_Podzol",
        "Dirt_Snow",
        "Dirt",
        "Emerald_Block",
        "Emerald_Ore",
        "Enchanting_Table",
        "End_Stone",
        "Farmland",
        "Furnace_On",
        "Furnace",
        "Glass",
        "Glazed_Terracotta_Light_Blue",
        "Glazed_Terracotta_Orange",
        "Glazed_Terracotta_White",
        "Glowstone",
        "Gold_Block",
        "Gold_Ore",
        "Grass",
        "Gravel",
        "Hardened_Clay",
        "Ice_Packed",
        "Iron_Block",
        "Iron_Ore",
        "Lapis_Ore",
        "Leaves_Birch",
        "Leaves_Jungle",
        "Leaves_Oak",
        "Leaves_Spruce",
        "Lectern_Book",
        "Log_Acacia",
        "Log_Birch",
        "Log_DarkOak",
        "Log_Jungle",
        "Log_Oak",
        "Log_Spruce",
        "Mycelium",
        "Nether_Brick",
        "Netherrack",
        "Obsidian",
        "Planks_Acacia",
        "Planks_Birch",
        "Planks_DarkOak",
        "Planks_Jungle",
        "Planks_Oak",
        "Planks_Spruce",
        "Quartz_Ore",
        "Red_Sand",
        "Red_Sandstone",
        "Redstone_Block",
        "Redstone_Ore",
        "Sand",
        "Sandstone",
        "Skeleton_Skull",
        "Snow",
        "Soul_Sand",
        "Stone_Andesite",
        "Stone_Diorite",
        "Stone_Granite",
        "Stone",
        "TNT",
        "Water",
        "Wool",
    ]
}
