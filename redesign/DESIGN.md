---
name: OpticFlow Pro
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#393939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#c7c4d7'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#908fa0'
  outline-variant: '#464554'
  surface-tint: '#c0c1ff'
  primary: '#c0c1ff'
  on-primary: '#1000a9'
  primary-container: '#8083ff'
  on-primary-container: '#0d0096'
  inverse-primary: '#494bd6'
  secondary: '#4cd7f6'
  on-secondary: '#003640'
  secondary-container: '#03b5d3'
  on-secondary-container: '#00424e'
  tertiary: '#ffb783'
  on-tertiary: '#4f2500'
  tertiary-container: '#d97721'
  on-tertiary-container: '#452000'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#c0c1ff'
  on-primary-fixed: '#07006c'
  on-primary-fixed-variant: '#2f2ebe'
  secondary-fixed: '#acedff'
  secondary-fixed-dim: '#4cd7f6'
  on-secondary-fixed: '#001f26'
  on-secondary-fixed-variant: '#004e5c'
  tertiary-fixed: '#ffdcc5'
  tertiary-fixed-dim: '#ffb783'
  on-tertiary-fixed: '#301400'
  on-tertiary-fixed-variant: '#703700'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
  mono-label:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 48px
  gutter: 16px
  sidebar-width: 280px
  toolbar-height: 56px
---

## Brand & Style
The design system is engineered for creative focus, positioning the product as a high-performance utility for digital artists and editors. The aesthetic prioritizes an immersive "darkroom" environment where the user's content remains the focal point, while the UI recedes into the background until needed.

The style is a blend of **Modern Minimalism** and **Technical Precision**. It utilizes deep charcoal surfaces to reduce eye strain during long creative sessions and leverages high-energy neon accents to signify interactivity and system status. The interface should feel like a premium piece of hardware—tactile, responsive, and unapologetically professional.

## Colors
The palette is built on a "Deep Surface" philosophy. The background uses a near-black charcoal to anchor the viewport, while containers and panels use a slightly lighter charcoal to establish hierarchy without breaking immersion.

- **Primary (Electric Indigo):** Used for primary actions, active selection states, and critical progress indicators.
- **Secondary (Cyan):** Reserved for supplemental data visualization, secondary toggles, and highlights.
- **Neutral/Surface:** A layered scale of greys (#121212 to #333333) provides the structural framework.
- **Accents:** Borders are kept subtle at #333333 to provide structure without creating visual noise.

## Typography
Inter is the workhorse of this design system, chosen for its exceptional legibility in technical interfaces and high-density data environments. 

For the "pro-tool" aesthetic, we utilize tight letter spacing on larger headlines to give a compact, engineered feel. Labels and metadata should often utilize the uppercase "Label-Caps" style or a monospaced font for technical values (like hex codes or coordinates) to reinforce the utility-first nature of the app.

## Layout & Spacing
The layout follows a **Fixed-Sidebar / Fluid-Canvas** model. The central workspace (the canvas) expands to fill all available space, while utility panels are docked to the edges with fixed widths.

- **Grid:** Use a 12-column grid for dashboard views, but switch to a custom flex-layout for the editor interface.
- **Density:** High density is preferred. Use 8px as the base unit for all margins and padding.
- **Breakpoints:** 
  - Mobile: < 768px (Single column, hidden sidebars)
  - Tablet: 768px - 1280px (Condensed sidebars)
  - Desktop: > 1280px (Expanded panels)

## Elevation & Depth
In this dark-mode system, depth is communicated through **Tonal Layering** and **Subtle Outlines** rather than heavy shadows.

- **Level 0 (Base):** #121212 - The main application background.
- **Level 1 (Panels):** #1B1B1B - Floating or docked sidebars and toolbars.
- **Level 2 (Modals/Popovers):** #252525 - Elements that sit on top of the panels, accompanied by a 1px border (#333) and a very soft, high-blur black shadow (0px 8px 24px rgba(0,0,0,0.5)).
- **Active State:** Elements being dragged or interacted with should gain a subtle outer glow using a low-opacity version of the Primary Indigo color.

## Shapes
A medium roundedness profile (8px) is applied to all primary UI components (buttons, input fields, cards). This softens the technical aesthetic, making the tool feel modern and approachable without losing its "pro" edge. 

Specific exceptions:
- **Canvas/Viewport:** 0px (Sharp) to maximize screen real estate for content.
- **Tool Icons:** 4px (Soft) for internal button grouping.
- **Search/Action Pills:** 32px (Full pill) for distinctive global search bars.

## Components
Consistent component styling ensures the interface remains predictable for high-speed workflows.

- **Buttons:** Primary buttons use a solid Indigo fill with white text. Secondary buttons use the #333 border with no fill.
- **Input Fields:** Darker than the panel color (#121212) with a 1px border. On focus, the border transitions to the Primary Indigo.
- **Chips/Badges:** Small, high-contrast labels used for tagging layers or image properties. Use the Secondary Cyan for "active" tags.
- **Lists:** Clean, tight vertical rhythm. Hover states should use a subtle highlight (#252525).
- **Tool Palette:** Small, square-ish buttons (40x40px) with 4px corner radius, utilizing clear iconography. Active tools are indicated by a 2px Indigo left-border or a subtle Indigo tint.
- **Cards:** Used for asset libraries. Minimalist styling with image-first priority and titles visible only on hover or in a small bottom bar.