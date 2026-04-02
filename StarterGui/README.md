Create ScreenGuis in StarterGui (release-ready layout):

- MainHUD
  - TextLabel CoinsLabel
  - Frame MainButtons
    - TextButton PlantButton
    - TextButton FreeShieldButton
    - TextButton PremiumShieldButton
    - TextButton HomeButton
    - TextButton LabButton
    - TextButton ShopButton
    - TextButton VisitButton
- InventoryUI
- LabUI
- ShopUI
- VisitUI
- ProtectionUI
- NotificationUI

Recommended defaults for MainHUD:

- `CoinsLabel`
  - Size: `UDim2.new(0, 260, 0, 48)`
  - Position: `UDim2.new(0, 20, 0, 20)`
- `MainButtons`
  - Size: `UDim2.new(0, 300, 0, 280)`
  - Position: `UDim2.new(0, 20, 1, -300)`
  - Add `UIListLayout` + `UIPadding` for clean spacing.

`MainHUD.client.lua` now auto-styles these controls with a greenhouse/lab palette and hover/click tweens.
