+------------------------+     +----------------------+
|   VR Application       |     |  OpenVR Game         |
|   (OpenXR native)      |     |  (e.g., SteamVR)     |
+-----------+------------+     +---------+------------+
            |                          |
            | (direct)                  | (needs translation)
            v                          v
+------------------------+     +------------------------+
|   OpenComposite        |     |                        |
|   (OpenVR -> OpenXR    |---->|   Monado               |
|    translation layer)  |     |   (OpenXR Runtime)     |
+------------------------+     +-----------+------------+
                                           |
                                           | provides frames & tracking
                                           v
                    +----------------------+----------------------+
                    |            Wireless Streaming Server         |
                    |  +-------------------+  +-----------------+  |
                    |  | WiVRn             |  | ALVR            |  |
                    |  | (built on Monado) |  | (standalone)    |  |
                    |  +--------+----------+  +-------+---------+  |
                    |           |                      |            |
                    |           +---------+------------+            |
                    |                     | (encodes video, sends   |
                    |                     |  over Wi-Fi)            |
                    +---------------------+------------------------+
                                          |
                                          | (UDP stream)
                                          v
+---------------------------------------------------------------+
|                      Oculus Quest 1 (Headset)                 |
|  +--------------------------+    +--------------------------+  |
|  | WiVRn Client             |    | ALVR Client              |  |
|  | (if using WiVRn)         |    | (if using ALVR)          |  |
|  +------------+-------------+    +-------------+------------+  |
|               |                                 |               |
|               +------------+--------------------+               |
|                            |                                    |
|                            v                                    |
|                  +---------+---------+                          |
|                  |   Headset Display  |                          |
|                  |   & Tracking       |                          |
|                  +-------------------+                          |
+---------------------------------------------------------------+

                    +------------------------+
                    |   wlx-overlay-s         |
                    |   (Desktop overlay      |
                    |    for Wayland/X11)     |
                    +-----------+-------------+
                                | (renders inside VR)
                                v
                    (Connects to Monado or SteamVR)

                    +------------------------+
                    |   Envision              |
                    |   (Stack manager:       |
                    |    builds/configures    |
                    |    Monado, WiVRn, etc.) |
                    +------------------------+