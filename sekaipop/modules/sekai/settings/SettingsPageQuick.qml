import QtQuick
import Quickshell
import qs.services

// Quick: the things you reach for most, so they're a tap away instead of a
// page deep. Everything here is also somewhere else (the Quick Panel's
// tiles, the bar's buttons, the General / Bar / Desktop pages); it's the
// same state, so changing it here shows up there at once.
SettingsPage {
    id: page

    readonly property var src: host ? host.source : null
    // The monitor the phone is on: with one theme per monitor, Colours picks for it
    // (ThemeService.pickTheme; the main monitor's is the shell's theme).
    readonly property string screenName: QsWindow.window && QsWindow.window.screen ? String(QsWindow.window.screen.name) : ""

    SectionCard {
        title: "Giao diện"

        SettingChoice {
            label: "Chế độ"
            sublabel: "Sáng, tối hoặc gần đen"
            current: ThemeService.mode
            options: [
                { id: "light", label: "Sáng", icon: "light_mode" },
                { id: "dark", label: "Tối", icon: "dark_mode" },
                { id: "darker", label: "Tối hơn", icon: "bedtime" }
            ]
            onPicked: id => ThemeService.setModeAndSystem(id)
        }

        SettingChoice {
            label: "Màu sắc"
            sublabel: "Chọn bộ màu cho shell"
            current: ThemeService.themeFor(page.screenName)
            options: ThemeService.groups.map(g => ({
                id: g.id,
                label: g.name,
                swatch: [g.c.border, g.c.A, g.c.B]
            }))
            onPicked: id => ThemeService.pickTheme(page.screenName, id)
        }

        SettingAction {
            tileWidth: 310
            icon: "palette"
            label: "Công cụ bảng màu"
            detail: "Lấy màu từ hình nền, âm nhạc hoặc ngẫu nhiên. Không thay đổi cho đến khi bạn áp dụng"
            onActivated: PaletteService.requestOpen()
        }
    }

    SectionCard {
        title: "Quick Panel"

        SettingChoice {
            label: "Điện thoại"
            sublabel: "Dạng nghiêng 2.5D hoặc phẳng 2D cho bảng này và Cài đặt (luôn phẳng trong Chế độ chơi game)"
            current: SettingsService.flag("quick.flat") ? "flat" : "tilted"
            options: [
                { id: "tilted", label: "2.5D", icon: "view_in_ar" },
                { id: "flat", label: "2D", icon: "crop_portrait" }
            ]
            onPicked: id => SettingsService.set("quick.flat", id === "flat")
        }

        SettingToggle {
            icon: "blur_on"
            label: "Bóng điện thoại"
            detail: "Bóng mềm dưới điện thoại (Bảng nhanh, Ứng dụng, Hình nền, Cài đặt)"
            checked: SettingsService.flag("quick.phoneShadow")
            onToggled: SettingsService.toggle("quick.phoneShadow")
        }
    }

    SectionCard {
        title: "Shell"

        SettingToggle {
            icon: page.src && page.src.notificationsOn ? "notifications_active" : "notifications_off"
            label: "Thông báo"
            checked: page.src ? page.src.notificationsOn : true
            onToggled: if (page.src) page.src.toggleNotifications()
        }

        SettingToggle {
            icon: "nightlight"
            label: "Ánh sáng đêm"
            checked: page.src ? page.src.nightLightOn : false
            onToggled: if (page.src) page.src.toggleNightLight()
        }

        SettingToggle {
            icon: "coffee"
            label: "Giữ máy hoạt động"
            checked: page.src ? page.src.keepAwakeOn : false
            onToggled: if (page.src) page.src.toggleKeepAwake()
        }

        SettingToggle {
            icon: "sports_esports"
            label: "Chế độ chơi game"
            checked: page.src ? page.src.gameModeOn : false
            onToggled: if (page.src) page.src.toggleGameMode()
        }

        SettingAction {
            icon: "wallpaper"
            label: "Hình nền"
            detail: "Mở trình chọn"
            onActivated: if (page.host) page.host.wallpapersRequested()
        }

        SettingStepper {
            icon: "aspect_ratio"
            label: "Kích thước shell"
            from: 0.5
            to: 3
            step: 0.05
            decimals: 2
            suffix: "×"
            value: page.host ? ShellScale.effectiveFor(page.host.screenName) : 1
            onMoved: v => { if (page.host) ShellScale.setScale(page.host.screenName, v) }
        }

        SettingToggle {
            icon: "dock_to_bottom"
            label: "Dock"
            checked: SettingsService.flag("dock.visible")
            onToggled: SettingsService.toggle("dock.visible")
        }

        SettingToggle {
            icon: "visibility"
            label: "Thanh"
            checked: SettingsService.flag("bar.visible")
            onToggled: SettingsService.toggle("bar.visible")
        }
    }

    SectionCard {
        title: "Thanh"

        SettingChoice {
            label: "Kiểu"
            current: BarStyleService.style
            options: [
                { id: "float", label: "Nổi", edge: "top", variant: "float" },
                { id: "straight", label: "Thẳng", edge: "top", variant: "straight" },
                { id: "transparent", label: "Trong suốt", edge: "top", variant: "transparent" },
                { id: "capsule", label: "Viên thuốc", edge: "top", variant: "capsule" }
            ]
            onPicked: id => BarStyleService.setStyle(id)
        }

        SettingChoice {
            label: "Vị trí"
            current: BarPositionService.position
            options: [
                { id: "top", label: "Trên", edge: "top" },
                { id: "right", label: "Phải", edge: "right" },
                { id: "bottom", label: "Dưới", edge: "bottom" },
                { id: "left", label: "Trái", edge: "left" }
            ]
            onPicked: id => BarPositionService.setPosition(id)
        }
    }

    SectionCard {
        title: "Tiện ích màn hình nền"

        SettingToggle {
            icon: "schedule"
            label: "Đồng hồ"
            checked: ClockService.shown
            onToggled: ClockService.setShown(!ClockService.shown)
        }

        SettingToggle {
            icon: "person"
            label: "Thẻ người dùng"
            checked: UserCardService.shown
            onToggled: UserCardService.setShown(!UserCardService.shown)
        }

        SettingToggle {
            icon: "partly_cloudy_day"
            label: "Thẻ thời tiết"
            checked: WeatherCardService.shown
            onToggled: WeatherCardService.setShown(!WeatherCardService.shown)
        }

        SettingToggle {
            icon: "calendar_month"
            label: "Thẻ lịch"
            checked: CalendarCardService.shown
            onToggled: CalendarCardService.setShown(!CalendarCardService.shown)
        }

        SettingToggle {
            icon: "palette"
            label: "Thẻ bảng màu"
            checked: PaletteService.shown
            onToggled: PaletteService.setShown(!PaletteService.shown)
        }

        SettingToggle {
            icon: "lyrics"
            label: "Lời bài hát"
            detail: "Hiển thị lời bài hát đang phát trên màn hình nền"
            checked: LyricsService.shown
            onToggled: LyricsService.setShown(!LyricsService.shown)
        }

        SettingToggle {
            icon: "task_alt"
            label: "Việc cần làm"
            checked: TodoService.shown
            onToggled: TodoService.setShown(!TodoService.shown)
        }

        SettingToggle {
            icon: "sticky_note_2"
            label: "Ghi chú"
            checked: NotesService.active
            onToggled: NotesService.setShown(!NotesService.active)
        }

        SettingToggle {
            icon: EditMode.widgetsLocked ? "lock" : "lock_open"
            label: "Khóa tiện ích"
            checked: EditMode.widgetsLocked
            onToggled: EditMode.toggleWidgetsLocked()
        }
    }
}
