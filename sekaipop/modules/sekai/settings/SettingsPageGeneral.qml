import QtQuick
import Quickshell
import qs.services
import qs.modules.common

// General: how the shell behaves, apart from how it looks. Time and units,
// what the Quick Panel and notifications do, the launcher, the lockscreen,
// and the shell itself.
SettingsPage {
    id: page

    SectionCard {
        title: "Thời gian và thông báo"

        SettingToggle {
            icon: "schedule"
            label: "Định dạng 24 giờ"
            checked: SettingsService.flag("time.use24h")
            onToggled: {
                const on = !SettingsService.flag("time.use24h")
                SettingsService.set("time.use24h", on)
                // The desktop clock card keeps its own copy of this.
                ClockService.setUse24h(on)
            }
        }

        SettingToggle {
            icon: "thermostat"
            label: "Fahrenheit"
            detail: SettingsService.flag("weather.fahrenheit") ? "°F" : "°C"
            checked: SettingsService.flag("weather.fahrenheit")
            onToggled: SettingsService.toggle("weather.fahrenheit")
        }

        SettingChoice {
            label: "Kiểu thông báo"
            sublabel: "Điện thoại: mở bảng điện thoại. Cửa sổ bật lên: xếp các thẻ ở góc màn hình"
            current: SettingsService.get("notify.style")
            options: [
                { id: "phone", label: "Điện thoại", icon: "smartphone" },
                { id: "popups", label: "Cửa sổ bật lên", icon: "notifications_active" }
            ]
            onPicked: id => SettingsService.set("notify.style", id)
        }

        SettingToggle {
            icon: "do_not_disturb_on"
            label: "Im lặng khi toàn màn hình"
            detail: "Không hiện thông báo hoặc rung khi có cửa sổ toàn màn hình. Thông báo vẫn nằm trong danh sách; thông báo khẩn cấp vẫn được hiển thị"
            checked: SettingsService.flag("notify.quietFullscreen")
            onToggled: SettingsService.toggle("notify.quietFullscreen")
        }

        SettingToggle {
            icon: "battery_alert"
            label: "Cảnh báo pin yếu"
            detail: "Thông báo khi pin còn 20, 15, 10 và 5%. Hai mức cuối là khẩn cấp và bỏ qua chế độ không làm phiền"
            checked: SettingsService.flag("battery.alerts")
            onToggled: SettingsService.toggle("battery.alerts")
        }

        SettingToggle {
            icon: "vibration"
            label: "Rung khi có thông báo"
            detail: SettingsService.get("notify.style") === "phone" ? "" : "Chỉ áp dụng cho thông báo điện thoại"
            checked: SettingsService.flag("notify.buzz")
            onToggled: SettingsService.toggle("notify.buzz")
        }

        SettingAction {
            icon: "clear_all"
            label: "Xóa tất cả"
            detail: page.host && page.host.notificationSource
                ? (page.host.notificationSource.count === 0 ? "Không có thông báo" : page.host.notificationSource.count + " thông báo đang chờ") : ""
            onActivated: if (page.host && page.host.notificationSource) page.host.notificationSource.clearAll()
        }
    }

    SectionCard {
        title: "Thời tiết"

        SettingText {
            label: "Vị trí"
            sublabel: "Nhập tên thành phố, ví dụ Hanoi hoặc Paris, France. Để trống để ước tính từ địa chỉ IP"
            value: SettingsService.get("weather.location")
            placeholder: "tự động (từ địa chỉ IP)"
            onSubmitted: text => SettingsService.set("weather.location", text)
            onCleared: SettingsService.set("weather.location", "")
        }

        SettingChoice {
            label: "Nội dung cửa sổ bật lên"
            sublabel: "Hàng bên dưới phần chi tiết"
            current: SettingsService.get("weather.view")
            options: [
                { id: "days", label: "Những ngày tới", icon: "calendar_view_week" },
                { id: "hourly", label: "Theo giờ", icon: "schedule" }
            ]
            onPicked: id => SettingsService.set("weather.view", id)
        }

    }

    SectionCard {
        title: "Vùng màn hình"

        SettingToggle {
            icon: "screenshot_region"
            label: "Dùng công cụ chọn vùng riêng"
            detail: "Áp dụng cho phím chụp và quay màn hình"
            checked: SettingsService.flag("region.own")
            onToggled: SettingsService.toggle("region.own")
        }

        SettingToggle {
            icon: "preview"
            label: "Xem trước sau khi chụp màn hình"
            detail: "Hiển thị thẻ để chú thích, sao chép hoặc lưu"
            checked: SettingsService.flag("region.preview")
            onToggled: SettingsService.toggle("region.preview")
        }

        SettingStepper {
            icon: "timer"
            label: "Thời gian xem trước"
            from: 2
            to: 20
            step: 1
            suffix: " s"
            value: SettingsService.get("region.previewSeconds")
            onMoved: v => SettingsService.set("region.previewSeconds", v)
        }

        SettingChoice {
            label: "Quay kèm âm thanh"
            sublabel: "Chọn nguồn âm thanh cho video"
            current: SettingsService.get("region.audio")
            options: [
                { id: "system", label: "Âm thanh hệ thống", icon: "volume_up" },
                { id: "mic", label: "Micrô", icon: "mic" }
            ]
            onPicked: id => SettingsService.set("region.audio", id)
        }

        SettingAction {
            icon: "crop_free"
            label: "Chọn vùng"
            detail: "Sao chép, lưu, nhận dạng chữ, tìm kiếm, quay"
            onActivated: {
                if (page.host) page.host.closeRequested()
                RegionService.showLater("copy")
            }
        }
    }

    SectionCard {
        title: "Quick Panel"

        SettingToggle {
            icon: "swipe_up"
            label: "Vùng kích hoạt ở cạnh màn hình"
            detail: SettingsService.flag("panel.hotEdge") ? "Giữa cạnh dưới" : "TẮT"
            checked: SettingsService.flag("panel.hotEdge")
            onToggled: SettingsService.toggle("panel.hotEdge")
        }

        SettingStepper {
            icon: "timer"
            label: "Độ trễ cạnh màn hình"
            from: 40
            to: 800
            step: 20
            suffix: " ms"
            value: SettingsService.get("panel.hotDwell")
            onMoved: v => SettingsService.set("panel.hotDwell", v)
        }

        SettingSlider {
            width: page.halfWidth
            icon: "vertical_align_top"
            label: "Phần điện thoại hiển thị"
            from: 40
            to: 100
            step: 2
            suffix: "%"
            value: SettingsService.get("panel.peek")
            onMoved: v => SettingsService.set("panel.peek", v)
        }

        SettingToggle {
            icon: "keyboard"
            label: "Gõ để tìm ứng dụng"
            detail: SettingsService.flag("panel.typeToSearch") ? "Gõ một chữ để mở Ứng dụng" : "TẮT"
            checked: SettingsService.flag("panel.typeToSearch")
            onToggled: SettingsService.toggle("panel.typeToSearch")
        }

        // Behind the Quick and Apps screens alike (PanelImages.phoneWallpaperFor). "A
        // picture" with none picked yet opens the chooser first, and only a picked
        // picture turns it on (PanelImages' picker), so cancelling changes nothing.
        SettingChoice {
            label: "Hình nền điện thoại"
            sublabel: "Hiển thị sau màn hình Quick và Ứng dụng. Desktop: dùng hình nền của màn hình đang chứa điện thoại"
            current: PanelImages.phoneMode
            options: [
                { id: "off", label: "Tắt", icon: "hide_image" },
                { id: "desktop", label: "Màn hình nền", icon: "wallpaper" },
                { id: "picture", label: "Một hình ảnh", icon: "image" }
            ]
            onPicked: id => {
                if (id === "picture" && PanelImages.phonePath === "")
                    PanelImages.pick("phone")
                else
                    SettingsService.set("phone.wallpaper", id)
            }
        }

        SettingAction {
            visible: PanelImages.phoneMode === "picture"
            icon: "add_photo_alternate"
            label: "Đổi hình điện thoại"
            detail: PanelImages.busy ? "Đang chọn…" : "Mở trình chọn tệp"
            busy: PanelImages.busy
            onActivated: PanelImages.pick("phone")
        }

        SettingAction {
            visible: PanelImages.phoneMode === "picture" && PanelImages.phone !== ""
            icon: "crop"
            label: "Điều chỉnh khung hình điện thoại"
            detail: "Chọn phần hình ảnh sẽ hiển thị"
            onActivated: {
                // The framer opens over the desktop; Settings (the phone) steps aside.
                if (page.host)
                    page.host.closeRequested()
                PanelImages.frame("phone", false, "")
            }
        }

        SettingChoice {
            label: "Trình chọn ảnh"
            sublabel: "Cửa sổ chọn ảnh đại diện, ảnh bìa hoặc hình nền điện thoại. Tự động: dùng KDE nếu đã cài. GTK / hệ thống sử dụng desktop portal và có thể chậm"
            current: SettingsService.get("files.chooser")
            options: [
                { id: "auto", label: "Tự động", icon: "auto_awesome" },
                { id: "kdialog", label: "KDE", icon: "folder_open" },
                { id: "zenity", label: "GTK / hệ thống", icon: "desktop_windows" },
                { id: "yad", label: "yad", icon: "folder" }
            ]
            onPicked: id => SettingsService.set("files.chooser", id)
        }
    }

    SectionCard {
        title: "Trình mở ứng dụng và khóa"

        SettingToggle {
            icon: "search"
            label: "Gợi ý tìm kiếm web"
            detail: SettingsService.flag("launcher.webSuggestions") ? "Gửi tới DuckDuckGo" : "TẮT"
            checked: SettingsService.flag("launcher.webSuggestions")
            onToggled: SettingsService.toggle("launcher.webSuggestions")
        }

        SettingToggle {
            icon: "content_paste"
            label: "Lịch sử bộ nhớ tạm"
            detail: SettingsService.flag("launcher.clipboard") ? "Đang ghi" : "TẮT"
            checked: SettingsService.flag("launcher.clipboard")
            onToggled: SettingsService.toggle("launcher.clipboard")
        }

        SettingChoice {
            label: "Thứ tự ứng dụng"
            sublabel: "Ưu tiên ứng dụng được mở nhiều gần đây, sau đó sắp xếp phần còn lại từ A đến Z. Chỉ tính ứng dụng mở từ màn hình Ứng dụng; thứ tự cập nhật khi mở lại màn hình"
            current: SettingsService.get("launcher.order")
            options: [
                { id: "az", label: "A đến Z", icon: "sort_by_alpha" },
                { id: "used", label: "Dùng nhiều nhất", icon: "history" }
            ]
            onPicked: id => SettingsService.set("launcher.order", id)
        }

        SettingChoice {
            label: "Kiểu màn hình khóa"
            sublabel: "Gacha: màn hình Project Sekai. Lịch: áp phích với các ảnh cắt từ hình nền"
            current: SettingsService.get("lock.style")
            options: [
                { id: "gacha", label: "Gacha", icon: "stars" },
                { id: "calendar", label: "Lịch", icon: "calendar_month" }
            ]
            onPicked: id => SettingsService.set("lock.style", id)
        }

        SettingChoice {
            visible: SettingsService.get("lock.style") === "calendar"
            label: "Hình ảnh lịch"
            sublabel: "Tự động tìm phần hình nền phù hợp (cần ImageMagick); Cố định luôn hiển thị cùng vị trí"
            current: SettingsService.get("lock.crop")
            options: [
                { id: "auto", label: "Tự động", icon: "auto_awesome" },
                { id: "fixed", label: "Cố định", icon: "crop" }
            ]
            onPicked: id => SettingsService.set("lock.crop", id)
        }

        SettingChoice {
            visible: SettingsService.get("lock.style") === "calendar"
            label: "Màu sắc lịch"
            sublabel: "Màu giữ nguyên màu hình nền và dùng màu chủ đề xung quanh; Đen trắng dùng áp phích đơn sắc"
            current: SettingsService.get("lock.tone")
            options: [
                { id: "color", label: "Màu", icon: "palette" },
                { id: "mono", label: "Đen trắng", icon: "contrast" }
            ]
            onPicked: id => SettingsService.set("lock.tone", id)
        }

        SettingToggle {
            visible: SettingsService.get("lock.style") === "calendar"
            icon: "power_settings_new"
            label: "Nút khởi động lại / tắt máy"
            detail: SettingsService.flag("lock.powerButtons") ? "Trên màn hình khóa Lịch" : "TẮT (Ctrl + Enter vẫn đưa máy vào sleep)"
            checked: SettingsService.flag("lock.powerButtons")
            onToggled: SettingsService.toggle("lock.powerButtons")
        }

        SettingToggle {
            icon: "lyrics"
            label: "Lời bài hát trên màn hình khóa"
            detail: SettingsService.flag("lock.lyrics")
                ? (SettingsService.get("lock.style") === "calendar" ? "Chỉ áp dụng cho màn hình khóa Gacha" : "Tìm lời bài hát đang phát từ các nhà cung cấp")
                : "TẮT"
            checked: SettingsService.flag("lock.lyrics")
            onToggled: SettingsService.toggle("lock.lyrics")
        }

        SettingToggle {
            icon: "bedtime"
            label: "Tạm dừng desktop khi khóa"
            detail: SettingsService.flag("lock.sleepDesktop") ? "Dỡ các tiện ích và ngừng thu âm thanh; mở khóa sẽ khôi phục" : "TẮT (mọi thứ tiếp tục chạy khi khóa)"
            checked: SettingsService.flag("lock.sleepDesktop")
            onToggled: SettingsService.toggle("lock.sleepDesktop")
        }

        SettingToggle {
            icon: "blur_on"
            label: "Làm mờ hình nền khóa"
            detail: SettingsService.get("lock.style") === "calendar" ? "Chỉ áp dụng cho màn hình khóa Gacha" : ""
            checked: SettingsService.flag("lock.blur")
            onToggled: SettingsService.toggle("lock.blur")
        }

        SettingToggle {
            icon: "auto_awesome"
            label: "Hiệu ứng màn hình khóa"
            detail: SettingsService.flag("lock.animations") ? (SettingsService.get("lock.style") === "calendar" ? "Chỉ áp dụng cho màn hình khóa Gacha" : "Bật hiệu ứng lấp lánh (tắt để giảm tải GPU)") : "TẮT (không có hiệu ứng lấp lánh, giảm tải GPU)"
            checked: SettingsService.flag("lock.animations")
            onToggled: SettingsService.toggle("lock.animations")
        }

        SettingToggle {
            icon: "fingerprint"
            label: "Mở khóa bằng vân tay"
            detail: SettingsService.flag("lock.fingerprint") ? "Quét đồng thời với ô mật khẩu (cần fprintd và vân tay đã đăng ký)" : "TẮT"
            checked: SettingsService.flag("lock.fingerprint")
            onToggled: SettingsService.toggle("lock.fingerprint")
        }

        SettingAction {
            icon: "lock"
            label: "Khóa ngay"
            detail: "Khóa màn hình"
            onActivated: {
                if (page.host)
                    page.host.closeRequested()
                LockState.lock()
            }
        }
    }

    // hypridle waits for these (IdleService.qml). A hypridle.conf that doesn't read
    // SekaiPop's file keeps its own times, so the switch comes first then.
    SectionCard {
        title: "Nhàn rỗi và sleep"

        Text {
            width: page.fullWidth
            text: "Thời gian không tương tác trước khi thực hiện. Keep Awake và video đang phát sẽ ngăn cả ba hành động."
            color: Theme.pInkSub
            font.family: Theme.fontFamily
            font.pixelSize: 15
            wrapMode: Text.WordWrap
        }

        SettingAction {
            visible: IdleService.linked === "no" || IdleService.linked === "missing"
            icon: "link"
            label: "Sử dụng các mốc này"
            detail: IdleService.linking ? "Đang chuyển…"
                : IdleService.linkError !== "" ? IdleService.linkError
                : IdleService.linked === "missing"
                    ? "Không có ~/.config/hypr/hypridle.conf nên máy không tự khóa hoặc sleep. Tạo file dùng các mốc này"
                    : "hypridle.conf có các mốc riêng nên cài đặt này chưa có tác dụng. Chuyển sang các mốc này (listener cũ được comment; bản sao lưu là hypridle.conf.sekaipop-bak)"
            busy: IdleService.linking
            onActivated: IdleService.link()
        }

        Text {
            visible: IdleService.linked === "yes" && !IdleService.running
            width: page.fullWidth
            text: "hypridle chưa chạy nên các hành động này sẽ không xảy ra. Nó được khởi động cùng Hyprland (execs.lua); chạy thủ công bằng: hypridle &"
            color: Theme.pInkSub
            font.family: Theme.fontFamily
            font.pixelSize: 15
            wrapMode: Text.WordWrap
        }

        SettingStepper {
            icon: "lock_clock"
            label: "Khóa sau"
            from: 0
            to: 120
            step: 1
            suffix: " phút"
            specialValue: 0
            specialText: "Không bao giờ"
            value: SettingsService.get("idle.lock")
            onMoved: v => SettingsService.set("idle.lock", v)
        }

        SettingStepper {
            icon: "desktop_access_disabled"
            label: "Tắt màn hình sau"
            from: 0
            to: 120
            step: 1
            suffix: " phút"
            specialValue: 0
            specialText: "Không bao giờ"
            value: SettingsService.get("idle.screenOff")
            onMoved: v => SettingsService.set("idle.screenOff", v)
        }

        SettingStepper {
            icon: "bedtime"
            label: SettingsService.get("idle.sleepAction") === "hibernate" ? "Ngủ đông sau" : "Sleep sau"
            from: 0
            to: 240
            step: 5
            suffix: " phút"
            specialValue: 0
            specialText: "Không bao giờ"
            value: SettingsService.get("idle.sleep")
            onMoved: v => SettingsService.set("idle.sleep", v)
        }

        SettingChoice {
            label: "Chế độ sleep"
            sublabel: IdleService.canHibernate === "no"
                ? "Máy chưa được cấu hình để ngủ đông (cần swap ít nhất bằng RAM và cấu hình khôi phục): chọn ngủ đông sẽ không có tác dụng"
                : "Tạm ngưng giữ phiên trong RAM và thức dậy nhanh. Ngủ đông ghi phiên xuống đĩa và tắt máy (cần đủ swap)"
            current: SettingsService.get("idle.sleepAction")
            options: [
                { id: "suspend", label: "Tạm ngưng", icon: "bedtime" },
                { id: "hibernate", label: "Ngủ đông", icon: "save" }
            ]
            onPicked: id => SettingsService.set("idle.sleepAction", id)
        }
    }

    SectionCard {
        title: "Shell"

        SettingAction {
            icon: "refresh"
            label: "Tải lại shell"
            detail: "Tạo lại mọi cửa sổ"
            onActivated: Quickshell.reload(true)
        }

        SettingAction {
            icon: "restart_alt"
            label: "Đặt lại cài đặt"
            detail: SettingsService.changedCount === 0 ? "Không có thay đổi"
                : SettingsService.changedCount + (SettingsService.changedCount === 1 ? " thay đổi" : " thay đổi")
            onActivated: SettingsService.reset()
        }
    }

    SectionCard {
        title: "Hook"

        Text {
            width: page.fullWidth
            text: "Chạy script tùy chỉnh khi có sự kiện hệ thống. Mỗi giá trị được truyền thành một đối số riêng. Phần gợi ý trong ô nhập cho biết thứ tự đối số."
            color: Theme.pInkSub
            font.family: Theme.fontFamily
            font.pixelSize: 15
            wrapMode: Text.WordWrap
        }

        Repeater {
            model: HookService.definitions
            delegate: Column {
                required property var modelData
                width: page.fullWidth
                spacing: 4

                Text {
                    width: parent.width
                    text: modelData.label
                    color: Theme.pInk
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    font.weight: Font.ExtraBold
                    font.styleName: Theme.fontStyleBold
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: modelData.args
                    color: Theme.pInkSub
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                }

                SettingText {
                    width: parent.width
                    label: ""
                    labelWidth: 0
                    value: SettingsService.get(modelData.key)
                    placeholder: modelData.example
                    onSubmitted: text => SettingsService.set(modelData.key, text);
                    onCleared: SettingsService.set(modelData.key, "");
                }
            }
        }
    }
}
