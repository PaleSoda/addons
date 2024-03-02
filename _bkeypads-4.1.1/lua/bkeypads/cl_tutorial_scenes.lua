-- Want to add your own tutorial scenes?
-- https://github.com/WilliamVenner/bkeypads-tutorials

-- This file is also loaded on the server so that models can be precached.
local function Model(mdl)
  util.PrecacheModel(mdl)
  return _G.Model(mdl)
end

if SERVER then bKeypads.Tutorial = {} end
local L = SERVER and function() end or bKeypads.L

bKeypads.Tutorial.Categories = {
  {
    Name = "Billy's Keypads",

    Scenes = {
      --[[{
        Name = "%YouTubeTutorials%",
        Tooltip = "%YouTubeTutorialsTip%",
      },]]

      {
        Name = "%Language%",
        Function = function()
          gui.ActivateGameUI()
          Derma_Message(L"TutorialLanguageMsg", "Billy's Keypads", L"Dismiss")
        end,
      },

      {
        Name = "%Settings%",
        Setting = "",
        Function = function()
          Derma_Message(L"TutorialSettingsMsg", "Billy's Keypads", L"Dismiss")
        end,
      },
    }
  },

  {
    Name = "%TutorialQuickStart%",

    Scenes = {
      "WHAT_IS_KEYPAD",
      "KEYPAD_PLACEMENT",
      "KEYPAD_ACCESS",
      "WHAT_IS_FADING_DOOR",
      "LINK_FADING_DOOR",
    }
  },

  --[=[{
    Name = "%Setting_Accessibility%",

    Scenes = {
      {
        Name = "%Setting_Dyslexia%",
        Setting = "dyslexia",
      },

      --[[{ TODO
        Name = "%Setting_ColorBlindness%",
        Setting = "color_blindness",
      },]]
    }
  },]=]

  {
    Name = "Keypads",

    Scenes = {
      {
        Shortcut = "WHAT_IS_KEYPAD",
        Name = "%TutorialWhatIsKeypad%",

        Frames = {
          {
            CameraFocus = "KEYPAD",
            CameraCenterZ = true,

            Caption = "%TutorialWhatIsKeypadCaption1%",
            Duration = 3,

            Objects = {
              {
                Class = "bkeypad",
                ID = "KEYPAD",
                Angle = Angle(0, -180, 0),

                NetworkVars = {
                  ScanningStatus = bKeypads.SCANNING_STATUS.IDLE,
                  AuthMode = bKeypads.AUTH_MODE.FACEID,
                  BackgroundColor = bKeypads.STOOL.RainbowBackgroundColor,
                }
              }
            }
          },

          {
            CircularCam = false,
            CameraFocus = "KEYPAD",
            CameraCenterZ = true,
            FOV = 90,

            Caption = "%TutorialWhatIsKeypadCaption2%",
            Duration = 4,

            Objects = {
              {
                Class = "bkeypad",
                ID = "KEYPAD",
                Angle = Angle(0, -90, 0),

                NetworkVars = {
                  ScanningStatus = bKeypads.SCANNING_STATUS.IDLE,
                  AuthMode = bKeypads.AUTH_MODE.PIN,
                }
              },
              {
                Class = "bkeypad",
                Translate = Vector(-10, 0, 0),
                Angle = Angle(0, -90, 0),

                NetworkVars = {
                  ScanningStatus = bKeypads.SCANNING_STATUS.IDLE,
                  AuthMode = bKeypads.AUTH_MODE.FACEID,
                  BackgroundColor = bKeypads.STOOL.RainbowBackgroundColor,
                }
              },
              {
                Class = "bkeypad",
                Translate = Vector(10, 0, 0),
                Angle = Angle(0, -90, 0),

                NetworkVars = {
                  ScanningStatus = bKeypads.SCANNING_STATUS.IDLE,
                  AuthMode = bKeypads.AUTH_MODE.KEYCARD,
                  BackgroundColor = bKeypads.STOOL.RainbowBackgroundColor,
                }
              },
            }
          },

          {
            Caption = "%TutorialWhatIsKeypadCaption3%",

            Objects = {
              {
                Class = "Player",
                ID = "PLAYER",
                Translate = Vector(-75, 0, 0),
                OutOfFrame = true,

                MasterSequence = true,
                Sequence = {
                  -- Walk towards fading door
                  {
                    WalkTo = Vector(-30, 0, 0),
                  },

                  -- Stop, scan
                  { Duration = bKeypads.Config.Scanning.ScanTimes.FaceID or 1.5 },

                  -- Open, wait
                  { Duration = .5 },

                  -- Walk through it
                  { WalkTo = Vector(30, 0, 0) },

                  {
                    "taunt_dance",
                    Duration = 2
                  }
                }
              },

              {
                Class = "prop_physics",
                Model = Model("models/props_building_details/Storefront_Template001a_Bars.mdl"),

                Sequence = {
                  nil,

                  nil,

                  { function(self) self:SetMaterial("models/wireframe") end },

                  nil,

                  { function(self) self:SetMaterial("") end },
                }
              },

              {
                Class = "bkeypad",
                Translate = Vector(-1.28, 0, 60),
                Angle = Angle(0, 180, 0),

                NetworkVars = {
                  ScanningStatus = bKeypads.SCANNING_STATUS.IDLE,
                  AuthMode = bKeypads.AUTH_MODE.FACEID,
                  BackgroundColor = 0x0096FF,
                },

                Sequence = {
                  nil,

                  {
                    function(self)
                      self:SetScanningStatus(bKeypads.SCANNING_STATUS.SCANNING)
                      self:SetScanningEntity(bKeypads.Tutorial:GetSceneObject("PLAYER"))
                      surface.PlaySound("npc/turret_floor/deploy.wav")

                      surface.PlaySound("npc/turret_floor/ping.wav")
                      timer.Create("bKeypads.Tutorial.ScanPing", self:GetScanPingInterval(), 0, function()
                        if not IsValid(self) or not bKeypads or not bKeypads.Tutorial or not IsValid(bKeypads.Tutorial.Menu) or not bKeypads.Tutorial.Menu:IsVisible() then timer.Remove("bKeypads.Tutorial.ScanPing") return end
                        surface.PlaySound("npc/turret_floor/ping.wav")
                      end)
                    end
                  },

                  {
                    function(self)
                      timer.Remove("bKeypads.Tutorial.ScanPing")
                      self:SetScanningStatus(bKeypads.SCANNING_STATUS.GRANTED)
                      self:SetScanningEntity(nil)
                      surface.PlaySound("buttons/button9.wav")
                    end
                  },

                  nil,

                  {
                    function(self)
                      self:SetScanningStatus(bKeypads.SCANNING_STATUS.IDLE)
                      surface.PlaySound("npc/turret_floor/retract.wav")
                    end
                  },
                }
              },
            }
          },
        }
      },

      --[[{
        Name = "%TutorialPlacingKeypads%",
        Tooltip = "%TutorialPlacingKeypadsTip%",
      },

      {
        Name = "%TutorialKeypadAppearance%",
        Tooltip = "%TutorialKeypadAppearanceTip%",
      },]]

      {
        Shortcut = "KEYPAD_ACCESS",
        Name = "%TutorialKeypadAccess%",
        Tooltip = "%TutorialKeypadAccessTip%",

        Frames = {
          {
            CameraFocus = "KEYPAD",
            CameraCenterZ = true,

            Caption = "%TutorialKeypadAccessCaption1%",
            Duration = 3,

            Objects = {
              {
                Class = "bkeypad",
                ID = "KEYPAD",
                Angle = Angle(0, -180, 0),

                NetworkVars = {
                  ScanningStatus = bKeypads.SCANNING_STATUS.IDLE,
                  AuthMode = bKeypads.AUTH_MODE.FACEID,
                  BackgroundColor = bKeypads.STOOL.RainbowBackgroundColor,
                }
              }
            }
          },

          {
            CircularCam = false,

            Caption = "%TutorialKeypadAccessCaption2%",
            Duration = 3,

            Objects = {
              {
                Class = "bkeypad",
                Angle = Angle(0, -90, 0),

                NetworkVars = {
                  ScanningStatus = bKeypads.SCANNING_STATUS.DENIED,
                  AuthMode = bKeypads.AUTH_MODE.FACEID,
                }
              },
              {
                Class = "bkeypad",
                Translate = Vector(-10, 0, 0),
                Angle = Angle(0, -90, 0),

                NetworkVars = {
                  ScanningStatus = bKeypads.SCANNING_STATUS.GRANTED,
                  AuthMode = bKeypads.AUTH_MODE.FACEID,
                }
              },
            }
          },

          {
            CircularCam = false,
            FOV = 80,
            Caption = "%TutorialKeypadAccessCaption3%",
            Duration = 4,

            Objects = {
              {
                Class = "Player",
                Angle = Angle(0, -90, 0),
                --Sequence = { { "gesture_wave" } },
              },
              {
                Class = "Player",
                Model = Model("models/player/monk.mdl"),
                Translate = Vector(-40, 0, 0),
                Angle = Angle(0, -90, 0),
                --Sequence = { { "gesture_agree" } },
              },
              {
                Class = "Player",
                Model = Model("models/player/police.mdl"),
                Translate = Vector(-80, 0, 0),
                Angle = Angle(0, -90, 0),
                --Sequence = { { "gesture_voicechat" } },
              },
              {
                Class = "Player",
                Model = Model("models/player/swat.mdl"),
                Translate = Vector(-120, 0, 0),
                Angle = Angle(0, -90, 0),
                --Sequence = { { "gesture_salute" } },
              }
            }
          },

          {
            Caption = "%TutorialKeypadAccessCaption4%",

            Panels = {
              {
                "DForm",

                function(self, w, h)
                  self:SetSize(w, h)
                  self:Center()

                  bKeypads.STOOL.BuildCPanel(self)

                  self.Think = self.bKeypads_Think
                  self.Paint = nil

                  self:GetChildren()[1]:SetVisible(false) -- Hide header

                  -- Hide children
                  for _, c in ipairs(self:GetChildren()[2]:GetChildren()[1]:GetChildren()) do
                    c:SetVisible(false)
                  end

                  -- Show access category
                  self.AccessCategory:GetParent():SetVisible(true)
                  self.AccessCategory:AuthModeChanged(bKeypads.AUTH_MODE.FACEID)

                  self:InvalidateChildren(true)
                end,
              }
            }
          },
        }
      },

      {
        Name = "%TutorialPaymentKeypads%",

        Frames = {
          {
            Caption = "%TutorialPaymentKeypadsCaption1%",
            CameraFocus = "KEYPAD",
            CameraCenterZ = true,
            CameraTranslate = Vector(0, 0, (scripted_ents.Get("bkeypad") or {PaymentPolyHeight = 2.5}).PaymentPolyHeight),
            SceneTranslate = Vector(0, 0, (scripted_ents.Get("bkeypad") or {PaymentPolyHeight = 2.5}).PaymentPolyHeight),

            Duration = 3,

            Objects = {
              {
                Class = "bkeypad",
                ID = "KEYPAD",
                Angle = Angle(0, -180, 0),

                NetworkVars = {
                  ScanningStatus = bKeypads.SCANNING_STATUS.IDLE,
                  AuthMode = bKeypads.AUTH_MODE.FACEID,
                  BackgroundColor = bKeypads.STOOL.RainbowBackgroundColor,
                  PaymentAmount = 500,
                }
              }
            }
          },

          {
            Caption = "%TutorialPaymentKeypadsCaption2%",
            CircularCam = false,
            CameraPos = Vector(-25, -30, 63),
            CameraAngle = Angle(0, 60, 0),

            Duration = 3,

            Objects = {
              {
                ID = "PLAYER",
                Class = "Player",
                Translate = Vector(-20, 0, 0),
              },
              {
                Class = "bkeypad",
                Angle = Angle(0, -180, 0),
                Translate = Vector(0, 0, 63),

                NetworkVars = {
                  ScanningStatus = bKeypads.SCANNING_STATUS.SCANNING,
                  AuthMode = bKeypads.AUTH_MODE.FACEID,
                  PaymentAmount = 500,
                },

                Sequence = {
                  {
                    function(self)
                      self:SetScanningStatus(bKeypads.SCANNING_STATUS.SCANNING)
                      self:SetScanningEntity(bKeypads.Tutorial:GetSceneObject("PLAYER"))
                      surface.PlaySound("npc/turret_floor/deploy.wav")

                      surface.PlaySound("npc/turret_floor/ping.wav")
                      timer.Create("bKeypads.Tutorial.ScanPing", self:GetScanPingInterval(), 0, function()
                        if not IsValid(self) or not bKeypads or not bKeypads.Tutorial or not IsValid(bKeypads.Tutorial.Menu) or not bKeypads.Tutorial.Menu:IsVisible() then timer.Remove("bKeypads.Tutorial.ScanPing") return end
                        surface.PlaySound("npc/turret_floor/ping.wav")
                      end)
                    end,

                    Duration = bKeypads.Config.Scanning.ScanTimes.FaceID or 1.5,
                  },

                  {
                    function(self)
                      timer.Remove("bKeypads.Tutorial.ScanPing")
                      self:SetScanningStatus(bKeypads.SCANNING_STATUS.DENIED)
                      self:SetScanningEntity(nil)
                      surface.PlaySound("buttons/button11.wav")
                    end
                  },
                }
              },
            }
          },

          {
            Caption = "%TutorialPaymentKeypadsCaption3%",
            CircularCam = false,
            CameraPos = Vector(-25, -30, 63),
            CameraAngle = Angle(0, 60, 0),

            Duration = 3,

            Objects = {
              {
                ID = "PLAYER",
                Class = "Player",
                Translate = Vector(-20, 0, 0),
              },
              {
                Class = "bkeypad",
                Angle = Angle(0, -180, 0),
                Translate = Vector(0, 0, 63),

                NetworkVars = {
                  ScanningStatus = bKeypads.SCANNING_STATUS.SCANNING,
                  AuthMode = bKeypads.AUTH_MODE.FACEID,
                  PaymentAmount = 500,
                },

                Sequence = {
                  {
                    function(self)
                      self:SetScanningStatus(bKeypads.SCANNING_STATUS.SCANNING)
                      self:SetScanningEntity(bKeypads.Tutorial:GetSceneObject("PLAYER"))
                      surface.PlaySound("npc/turret_floor/deploy.wav")

                      surface.PlaySound("npc/turret_floor/ping.wav")
                      timer.Create("bKeypads.Tutorial.ScanPing", self:GetScanPingInterval(), 0, function()
                        if not IsValid(self) or not bKeypads or not bKeypads.Tutorial or not IsValid(bKeypads.Tutorial.Menu) or not bKeypads.Tutorial.Menu:IsVisible() then timer.Remove("bKeypads.Tutorial.ScanPing") return end
                        surface.PlaySound("npc/turret_floor/ping.wav")
                      end)
                    end,

                    Duration = bKeypads.Config.Scanning.ScanTimes.FaceID or 1.5,
                  },

                  {
                    function(self)
                      timer.Remove("bKeypads.Tutorial.ScanPing")
                      self:SetScanningStatus(bKeypads.SCANNING_STATUS.GRANTED)
                      self:SetScanningEntity(nil)
                      surface.PlaySound("buttons/button9.wav")

                      self.Particles = CreateParticleSystem(self, "bkeypads_cash", PATTACH_POINT, 0, self:WorldSpaceCenter())
                      self.Particles:SetShouldDraw(false)
                    end
                  },
                }
              },
            }
          },

          {
            Caption = "%TutorialPaymentKeypadsCaption4%",
            CameraFocus = "KEYPAD",
            CameraCenterZ = true,
            CameraTranslate = Vector(0, 0, (scripted_ents.Get("bkeypad") or {PaymentPolyHeight = 2.5}).PaymentPolyHeight),
            SceneTranslate = Vector(0, 0, (scripted_ents.Get("bkeypad") or {PaymentPolyHeight = 2.5}).PaymentPolyHeight),

            Duration = 3,

            Objects = {
              {
                Class = "bkeypad",
                ID = "KEYPAD",
                Angle = Angle(0, -180, 0),

                NetworkVars = {
                  ScanningStatus = bKeypads.SCANNING_STATUS.IDLE,
                  AuthMode = bKeypads.AUTH_MODE.FACEID,
                  BackgroundColor = bKeypads.STOOL.RainbowBackgroundColor,
                  PaymentAmount = 500,
                },

                Sequence = { { function(self) self.m_bRequiresPayment = false end } }
              }
            }
          },
        },
      },

      --"LINK_KEYPADS",
    }
  },

  --[[
  {
    Name = "%TutorialKeypadTypes%",

    Scenes = {
      {
        Name = "%PIN%",
        Tooltip = "%TutorialPINTip%",
      },

      {
        Name = "%FaceID%",
        Tooltip = "%TutorialFaceIDTip%",
      },

      {
        Name = "%KeycardScanner%",
        Tooltip = "%TutorialKeycardScannerTip%",
      },

      "KEYPAD_ACCESS",
    }
  },]]

  {
    Name = "%tool.bkeypads_fading_door.name%",

    Scenes = {
      {
        Shortcut = "WHAT_IS_FADING_DOOR",
        Name = "%TutorialWhatIsFadingDoor%",

        Frames = {
          {
            Caption = "%TutorialWhatIsFadingDoorCaption%",

            Objects = {
              {
                Class = "Player",
                Translate = Vector(-75, 0, 0),
                OutOfFrame = true,

                MasterSequence = true,
                Sequence = {
                  -- Walk towards fading door
                  {
                    WalkTo = Vector(-20, 0, 0),
                  },

                  -- Stop, wait
                  { Duration = .5 },

                  -- Open, wait
                  { Duration = .5 },

                  -- Walk through it
                  {
                    WalkTo = Vector(75, 0, 0),
                  },
                }
              },

              {
                Class = "prop_physics",
                Model = Model("models/props_building_details/Storefront_Template001a_Bars.mdl"),

                Sequence = {
                  nil,

                  nil,

                  { function(self) self:SetMaterial("models/wireframe") end },

                  nil,

                  {
                    function(self) self:SetMaterial("") end,
                    Duration = 2
                  },
                }
              },
            }
          },

          {
            Caption = "%TutorialWhatIsFadingDoorCaption2%",

            Objects = {
              {
                Class = "Player",
                Translate = Vector(-60, 0, 0),
                OutOfFrame = true,

                Weapon = "models/weapons/w_toolgun.mdl",
                HoldType = "revolver",

                MasterSequence = true,
                Sequence = {
                  { Duration = 1 },

                  { ShootToolgun = "FADING_DOOR", Duration = 2 },
                },
              },

              {
                ID = "FADING_DOOR",
                Class = "prop_physics",
                Model = Model("models/props_building_details/Storefront_Template001a_Bars.mdl"),

                Sequence = {
                  { Halo = { Color = color_white, BlurX = 1, BlurY = 1, DrawPasses = 2, Additive = true, IgnoreZ = false } },

                  { Halo = { Color = bKeypads.COLOR.PINK, BlurX = 1, BlurY = 1, DrawPasses = 2, Additive = true, IgnoreZ = false } },
                },
              },
            }
          },

          {
            Caption = "%TutorialWhatIsFadingDoorCaption3%",

            Objects = {
              {
                Class = "Player",
                Translate = Vector(-150, 0, 0),
                OutOfFrame = true,

                MasterSequence = true,
                Sequence = {
                  -- Walk towards fading door
                  { WalkTo = Vector(0, 0, 0) },

                  -- Stop, wait
                  { Caption = "%TutorialWhatIsFadingDoorCaption4%", Duration = 1 },

                  -- Walk out of it
                  { WalkTo = Vector(150, 0, 0) },
                }
              },

              {
                Class = "prop_physics",
                Model = Model("models/props_building_details/Storefront_Template001a_Bars.mdl"),
                Material = "models/wireframe",

                Sequence = {
                  nil,

                  nil,

                  {
                    function(self)
                      timer.Simple(.25, function()
                        if not IsValid(self) then return end
                        self:SetMaterial("")
                      end)
                    end,
                  },
                }
              },
            }
          },
        }
      },

      --[[{
        Name = "%TutorialConfiguringFadingDoors%",
      },]]

      "LINK_FADING_DOOR"
    }
  },

  {
    Name = "%Linking%",

    Scenes = {
      --[[{
        Shortcut = "LINK_KEYPADS",
        Name = "%TutorialLinkingKeypads%",
        Tip = "%TutorialLinkingKeypadsTip%",
      },]]

      {
        Shortcut = "LINK_FADING_DOOR",
        Name = "%TutorialLinkingFadingDoors%",
        Tip = "%TutorialLinkingFadingDoorsTip%",

        Frames = {
          {
            CircularCam = false,
            CircularCamFactor = .5 * math.pi,
            Caption = "%TutorialLinkingFadingDoorsStep1%",
            Raycast = true,

            Objects = {
              {
                ID = "PLAYER",
                Class = "Player",
                Translate = Vector(-150, 0, 0),
                OutOfFrame = true,

                Weapon = "models/weapons/w_toolgun.mdl",
                HoldType = "revolver",

                MasterSequence = true,
                Sequence = {
                  -- Walk towards fading door
                  { WalkTo = Vector(-60, 0, 0) },

                  -- Look at the fading door
                  {
                    LookAt = "FADING_DOOR",
                    Duration = 1,
                  },

                  -- Shoot toolgun
                  { ShootToolgun = "FADING_DOOR", Duration = 1 },

                  -- Look at the keypad
                  {
                    function() surface.PlaySound("npc/combine_soldier/gear5.wav") end,

                    Caption = "%TutorialLinkingFadingDoorsStep2%",
                    LookAt = "KEYPAD",
                    Duration = 2,
                  },

                  -- Shoot toolgun
                  {
                    ShootToolgun = "KEYPAD",
                    Duration = 2,
                    DrawLinkingBeam = { "KEYPAD", {"FADING_DOOR"}, bKeypads.COLOR.GREEN },
                  },

                  -- Look at the fading door
                  {
                    Caption = "%TutorialLinkingFadingDoorsStep3%",
                    LookAt = "FADING_DOOR",
                    Duration = 2,

                    DrawLinkingBeam = { "KEYPAD", {"FADING_DOOR"}, bKeypads.COLOR.GREEN },
                  },

                  -- Shoot toolgun
                  {
                    Caption = "%TutorialEasy%",
                    ShootToolgun = "FADING_DOOR",
                    DrawLinkingBeam = { "KEYPAD", "FADING_DOOR", bKeypads.COLOR.GREEN, false, true },
                    Duration = 2
                  },

                  -- Unequip toolgun
                  {
                    Caption = "%TutorialLinkingFadingDoorsStep4%",
                    Weapon = false,
                    Duration = 1,
                  },

                  -- Look at keypad
                  {
                    LookAt = "KEYPAD",
                    Duration = 1,
                  },

                  -- Scan
                  { Duration = bKeypads.Config.Scanning.ScanTimes.FaceID or 1.5 },

                  -- Open, wait
                  {
                    LookAt = "FADING_DOOR",
                    Caption = "%TutorialLinkingFadingDoorsStep5%",
                    Duration = 1
                  },

                  -- Walk through it
                  { WalkTo = Vector(60, 0, 0) },

                  {
                    "taunt_dance",
                    Duration = 2
                  }
                }
              },

              {
                Class = "prop_physics",
                Model = Model("models/hunter/plates/plate05x05.mdl"),
                Material = "phoenix_storms/metalset_1-2",
                Angle = Angle(90, 45, 0),
                Translate = Vector(-10, 50, 60),
              },

              {
                ID = "FADING_DOOR",
                Class = "prop_physics",
                Model = Model("models/props_building_details/Storefront_Template001a_Bars.mdl"),

                Sequence = {
                  nil,

                  { Halo = { Color = color_white, BlurX = 1, BlurY = 1, DrawPasses = 2, Additive = true, IgnoreZ = false } },

                  { Halo = { Color = bKeypads.COLOR.PINK, BlurX = 1, BlurY = 1, DrawPasses = 2, Additive = true, IgnoreZ = false } },

                  nil,

                  nil,

                  { Halo = { Raycast = true, Color = bKeypads.COLOR.GREEN, BlurX = 1, BlurY = 1, DrawPasses = 2, Additive = true, IgnoreZ = false } },

                  { Halo = { Color = bKeypads.COLOR.GREEN, BlurX = 1, BlurY = 1, DrawPasses = 2, Additive = true, IgnoreZ = false } },

                  nil,

                  nil,

                  nil,

                  { function(self) self:SetMaterial("models/wireframe") end },

                  nil,

                  { function(self) self:SetMaterial("") end },
                },
              },

              {
                ID = "KEYPAD",
                Class = "bkeypad",
                Translate = Vector(-10 + 1.75 - (4.252956 / 2), 50 + (4.252956 / 2), 60 + (5.782784 / 2)),
                Angle = Angle(0, 180 + 45, 0),

                NetworkVars = {
                  ScanningStatus = bKeypads.SCANNING_STATUS.IDLE,
                  AuthMode = bKeypads.AUTH_MODE.FACEID,
                  BackgroundColor = 0x0096FF
                },

                Sequence = {
                  nil,

                  nil,

                  nil,

                  nil,

                  { Halo = { Color = bKeypads.COLOR.GREEN, BlurX = 1, BlurY = 1, DrawPasses = 2, Additive = true, IgnoreZ = false } },

                  { Halo = { Color = bKeypads.COLOR.GREEN, BlurX = 1, BlurY = 1, DrawPasses = 2, Additive = true, IgnoreZ = false } },

                  { Halo = { Color = bKeypads.COLOR.GREEN, BlurX = 1, BlurY = 1, DrawPasses = 2, Additive = true, IgnoreZ = false } },

                  nil,

                  nil,

                  {
                    function(self)
                      self:SetScanningStatus(bKeypads.SCANNING_STATUS.SCANNING)
                      self:SetScanningEntity(bKeypads.Tutorial:GetSceneObject("PLAYER"))
                      surface.PlaySound("npc/turret_floor/deploy.wav")

                      surface.PlaySound("npc/turret_floor/ping.wav")
                      timer.Create("bKeypads.Tutorial.ScanPing", self:GetScanPingInterval(), 0, function()
                        if not IsValid(self) or not bKeypads or not bKeypads.Tutorial or not IsValid(bKeypads.Tutorial.Menu) or not bKeypads.Tutorial.Menu:IsVisible() then timer.Remove("bKeypads.Tutorial.ScanPing") return end
                        surface.PlaySound("npc/turret_floor/ping.wav")
                      end)
                    end
                  },

                  {
                    function(self)
                      timer.Remove("bKeypads.Tutorial.ScanPing")
                      self:SetScanningStatus(bKeypads.SCANNING_STATUS.GRANTED)
                      self:SetScanningEntity(nil)
                      surface.PlaySound("buttons/button9.wav")
                    end
                  },

                  nil,

                  {
                    function(self)
                      self:SetScanningStatus(bKeypads.SCANNING_STATUS.IDLE)
                      surface.PlaySound("npc/turret_floor/retract.wav")
                    end
                  },
                }
              },
            },
          },
        },
      },

      --"MAP_OBJECTS",
    }
  },

  --[[
  {
    Name = "%MapObjects%",

    Scenes = {
      {
        Shortcut = "MAP_OBJECTS",
        Name = "%MapObjects%",
        Tip = "%TutorialLinkingMapObjectsTip%",
      },

      {
        Name = "%TutorialMapDoors%",
      },

      {
        Name = "%TutorialMapButtons%",
      },
    }
  },]]
}

if SERVER then
  AddCSLuaFile()
  bKeypads.Tutorial = nil
else
  hook.Run("bKeypads.TutorialScenes")
end