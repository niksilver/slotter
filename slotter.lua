-- slotter
-- v0.1
--
-- Slot sounds together

Sample = include 'lib/Sample'

sample371 = Sample:new {
    filename = '/home/we/dust/audio/tape/carnage1.wav',
    level = 1,
    rate = 1,
    start = 0,
    duration = 10,
}

-- The pages we have

PAGES = {
    RECORD = 'RECORD',
    SPLIT = 'SPLIT',
}

-- State of the app; this isn't saved

app = {
    page = PAGES.RECORD,
    playing = 0,
}

function init()
    load_sample(1, sample371)
end

function load_sample(voice, sample)
    softcut.buffer_read_mono(
        sample.filename,
        sample.start,    -- File start
        0,    -- Buffer start
        sample.duration,    -- Sample duration
        1,    -- File channel to read
        1,    -- Buffer to write to
        0.0,    -- Preserve level
        1.0)    -- Write level

    softcut.enable(voice, 1)
    softcut.buffer(voice, 1)
    softcut.level(voice, sample.level)
    softcut.loop(voice, 1)
    softcut.loop_start(voice, sample.start)
    softcut.loop_end(voice, sample.start + sample.duration)
    softcut.position(voice, sample.start)
    softcut.rate(voice, sample.rate)

    softcut.play(voice, app.playing)

    redraw()
end

function key(n, z)
    if n == 2 and z == 1 then
        app.playing = 1 - app.playing
        softcut.play(1, app.playing)
        redraw()
    end
end

function redraw()
    screen.clear()

    screen.move(0,8)
    screen.text(app.playing == 1 and 'Playing' or 'Stopped')

    screen.update()
end
