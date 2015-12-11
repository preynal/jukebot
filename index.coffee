request = require "request"
notifier = require "node-notifier"
{execSync} = require "child_process"
cheerio = require "cheerio"

# Instructions:
# Go to https://www.jukely.com/unlimited/shows
# in the adress bar type: javascript:alert(document.cookie);
# paste the cookie here
COOKIE = ""
# Paste the title of the show as is
TITLE = "Seth Troxler"

fn = () ->
    request
        url: "https://www.jukely.com/unlimited/shows"
        headers:
            "Cookie": COOKIE
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
    , (err, res, body) ->
        throw err if err?
        $ = cheerio.load body
        [target_event] = $("[data-react-class='Unlimited']")
            .data()
            .reactProps.events.filter (event) ->
                event.title is TITLE
        unless target_event.status is 3
            notifier.notify
                title: "JUKELY ALERT"
                message: "#{TITLE} IS NOW AVAILABLE!!!"
            # Experimental! (I think they changed smth in the structure so this might not work)
            # books the ticked automatically
            id = target_event.parse_id
            execSync "open https://www.jukely.com/s/#{id}/unlimited_rsvp"
        else console.log "not yet"


# Tweak interval, 3 mins is ok, but you might need to lower it to 1 or 2 mins
INTERVAL = 3 * 60 * 1000 # 3 mins
setInterval fn, INTERVAL
# Trigger first run
fn()
