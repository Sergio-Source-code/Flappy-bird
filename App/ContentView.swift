import SwiftUI

struct ContentView: View {
    @State private var game = Game()
    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let playH = game.playHeight(size)
            let birdY = game.state == .ready ? playH / 2 : game.birdY

            ZStack(alignment: .topLeading) {
                LinearGradient(colors: [.cyan, Color(red: 0.7, green: 0.9, blue: 1)],
                               startPoint: .top, endPoint: .bottom)

                ForEach(game.pipes) { p in
                    let topH = p.gapY - game.gapHeight / 2
                    let botY = p.gapY + game.gapHeight / 2
                    let botH = playH - botY
                    pipeShape
                        .frame(width: game.pipeWidth, height: max(topH, 0))
                        .position(x: p.x + game.pipeWidth / 2, y: topH / 2)
                    pipeShape
                        .frame(width: game.pipeWidth, height: max(botH, 0))
                        .position(x: p.x + game.pipeWidth / 2, y: botY + botH / 2)
                }

                Rectangle()
                    .fill(Color(red: 0.87, green: 0.8, blue: 0.5))
                    .overlay(alignment: .top) { Rectangle().fill(.green).frame(height: 12) }
                    .frame(width: size.width, height: game.groundHeight)
                    .position(x: size.width / 2, y: playH + game.groundHeight / 2)

                bird
                    .rotationEffect(.degrees(game.state == .ready ? 0 : Double(min(max(game.velocity / 8, -30), 80))))
                    .position(x: game.birdX, y: birdY)

                VStack(spacing: 8) {
                    Text("\(game.score)")
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(radius: 3)
                    if game.state == .ready {
                        Text("Tap to flap").font(.title2.bold()).foregroundStyle(.white).shadow(radius: 2)
                    } else if game.state == .over {
                        VStack(spacing: 4) {
                            Text("Game Over").font(.title.bold())
                            Text("Best: \(game.best)")
                            Text("Tap to restart").font(.subheadline).foregroundStyle(.secondary)
                        }
                        .padding(20)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .frame(width: size.width)
                .padding(.top, 80)
            }
            .contentShape(Rectangle())
            .onTapGesture { game.tap(size: size) }
            .onReceive(timer) { game.tick(now: $0, size: size) }
        }
        .ignoresSafeArea()
    }

    private var pipeShape: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(red: 0.2, green: 0.7, blue: 0.2))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(red: 0.1, green: 0.4, blue: 0.1), lineWidth: 3))
    }

    private var bird: some View {
        ZStack {
            Circle().fill(.yellow).frame(width: 28, height: 28)
                .overlay(Circle().stroke(.orange, lineWidth: 2))
            Circle().fill(.white).frame(width: 10, height: 10).offset(x: 6, y: -5)
            Circle().fill(.black).frame(width: 4, height: 4).offset(x: 8, y: -5)
            Capsule().fill(.orange).frame(width: 12, height: 6).offset(x: 14, y: 3)
        }
    }
}
