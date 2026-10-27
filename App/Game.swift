import SwiftUI
import Observation

@Observable
final class Game {
    enum State { case ready, playing, over }

    struct Pipe: Identifiable {
        let id = UUID()
        var x: CGFloat
        let gapY: CGFloat
        var scored = false
    }

    let birdX: CGFloat = 100
    let birdRadius: CGFloat = 14
    let pipeWidth: CGFloat = 64
    let gapHeight: CGFloat = 170
    let groundHeight: CGFloat = 90
    private let pipeSpacing: CGFloat = 230
    private let speed: CGFloat = 150
    private let gravity: CGFloat = 1500
    private let flapVelocity: CGFloat = -460

    var state: State = .ready
    var birdY: CGFloat = 0
    var velocity: CGFloat = 0
    var pipes: [Pipe] = []
    var score = 0
    var best = UserDefaults.standard.integer(forKey: "flappyBest")
    private var lastTick: Date?

    func playHeight(_ size: CGSize) -> CGFloat { size.height - groundHeight }

    func tap(size: CGSize) {
        switch state {
        case .ready:
            birdY = playHeight(size) / 2
            velocity = flapVelocity
            state = .playing
            lastTick = nil
        case .playing:
            velocity = flapVelocity
        case .over:
            pipes = []
            score = 0
            velocity = 0
            state = .ready
        }
    }

    func tick(now: Date, size: CGSize) {
        guard state == .playing, size.width > 0 else { lastTick = now; return }
        let dt = min(CGFloat(now.timeIntervalSince(lastTick ?? now)), 1.0 / 30.0)
        lastTick = now

        velocity += gravity * dt
        birdY += velocity * dt

        let playH = playHeight(size)
        if pipes.last.map({ $0.x < size.width - pipeSpacing }) ?? true {
            let margin: CGFloat = 70
            let lo = gapHeight / 2 + margin
            let hi = playH - gapHeight / 2 - margin
            pipes.append(Pipe(x: size.width + pipeWidth, gapY: CGFloat.random(in: lo...hi)))
        }

        for i in pipes.indices {
            pipes[i].x -= speed * dt
            if !pipes[i].scored && pipes[i].x + pipeWidth < birdX - birdRadius {
                pipes[i].scored = true
                score += 1
            }
        }
        pipes.removeAll { $0.x < -pipeWidth }

        var hit = birdY + birdRadius > playH || birdY - birdRadius < 0
        for p in pipes where birdX + birdRadius > p.x && birdX - birdRadius < p.x + pipeWidth {
            if birdY - birdRadius < p.gapY - gapHeight / 2 || birdY + birdRadius > p.gapY + gapHeight / 2 {
                hit = true
            }
        }
        if hit { gameOver(playH: playH) }
    }

    private func gameOver(playH: CGFloat) {
        birdY = min(birdY, playH - birdRadius)
        state = .over
        if score > best {
            best = score
            UserDefaults.standard.set(best, forKey: "flappyBest")
        }
    }
}
