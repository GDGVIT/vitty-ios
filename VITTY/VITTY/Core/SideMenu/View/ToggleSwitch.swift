//
//  ToggleSwitch.swift
//  VITTY
//
//  Created by Prashanna Rajbhandari on 22/08/2023.
//

import SwiftUI

struct ToggleView<Content: View>: View {
    @Binding var isOn: Bool
    var backGround: Content
    var toggleButton: Content?

    init(isOn: Binding<Bool>, @ViewBuilder backGround: @escaping () -> Content, @ViewBuilder button: @escaping () -> Content? = { nil }) {
        _isOn = isOn
        self.backGround = backGround()
        toggleButton = button()
    }

    var body: some View {
        GeometryReader { reader in
            HStack {
                if isOn {
                    Spacer()
                }
                VStack {
                    if let toggleButton = toggleButton {
                        toggleButton
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.theme.brightBlue)
                    }
                }.padding(2.5)
                    .frame(width: reader.frame(in: .global).height)

                    .onTapGesture {
                        withAnimation {
                            isOn.toggle()
                        }
                    }.modifier(Swipe { direction in
                        if direction == .swipeLeft {
                            withAnimation {
                                isOn = true
                            }
                        } else if direction == .swipeRight {
                            withAnimation {
                                isOn = false
                            }
                        }
                    })
                if !isOn {
                    Spacer()
                }
            }.background(backGround)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.theme.primary, lineWidth: 2)
                )
                .frame(width: 60, height: 30)
        }
    }
}

struct Swipe: ViewModifier {
    @GestureState private var dragDirection: Direction = .none
    @State private var lastDragPosition: DragGesture.Value?
    @State var position = Direction.none
    var action: (Direction) -> Void

    func body(content: Content) -> some View {
        content
            .gesture(DragGesture().onChanged { value in
                lastDragPosition = value
            }.onEnded { value in
                if lastDragPosition != nil {
                    if (lastDragPosition?.location.x)! < value.location.x {
                        withAnimation {
                            action(.swipeRight)
                        }
                    } else if (lastDragPosition?.location.x)! > value.location.x {
                        withAnimation {
                            action(.swipeLeft)
                        }
                    }
                }
            })
    }
}

enum Direction {
    case none
    case swipeLeft
    case swipeRight
    case swipeUp
    case swipeDown
}

struct ToggleSwitch: View {
    @State var isOn: Bool = false
    var body: some View {
        VStack {
            ToggleView(isOn: $isOn) {
                Color.theme.secondaryBlue
            }.frame(width: 60, height: 30)
        }
    }
}

struct ToggleSwitch_Previews: PreviewProvider {
    static var previews: some View {
        ToggleSwitch()
    }
}
