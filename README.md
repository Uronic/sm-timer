# Influx Timer (Really minor MG Edit)
![Influx Logo](https://github.com/TotallyMehis/Influx-Timer/blob/master/web/img/inflogo.png "Influx Logo")

Please visit the site [influxtimer.com](https://influxtimer.com/) for latest stable version with compiled *.smx files.

So basically I wanted to make influx work on my mg timer but a lot of things were not going my way so I thought I would try editing the plugin a bit, I basically removed the style function (removed all other styles except normal), I also made it so that mode_auto_csgo.sp wouldn't edit cvars anymore (late loading issues).

The way I've found that you could load/unload this plugin so far was (At least with my edit):
In server.cfg:
```
sm plugins unload influx_core
```

In per-map config:
```
sm plugins load influx_core
sm plugins reload influx_hud
sm plugins reload influx_hud_draw
sm plugins reload influx_hud_draw_csgo
sm plugins reload influx_hud_hidehud
sm plugins reload influx_hud_hideplayers
sm plugins reload influx_hud_recchat
sm plugins reload influx_hud_recsounds
sm plugins reload influx_jumps
sm plugins reload influx_maprankings
sm plugins reload influx_mode_auto_csgo
sm plugins reload influx_prespeed
sm plugins reload influx_recchat
sm plugins reload influx_recordsmenu
sm plugins reload influx_recrank
sm plugins reload influx_recsounds
sm plugins reload influx_strafes
sm plugins reload influx_strfsync
sm plugins reload influx_style_normal
sm plugins reload influx_truevel
sm plugins reload influx_zones
sm plugins reload influx_zones_autobhop
sm plugins reload influx_zones_beams
sm plugins reload influx_zones_block
sm plugins reload influx_zones_checkpoint
sm plugins reload influx_zones_freestyle
sm plugins reload influx_zones_stage
sm plugins reload influx_printcptimes
sm plugins reload influx_zones_teleport
sm plugins reload influx_zones_timer
sm plugins reload influx_zones_validator
```

Oh btw you should edit influx_hud_draw_csgo.sp on line 465 to your needs
