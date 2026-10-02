---
name: Haute Joaillerie & Street Luxury
colors:
  surface: '#fcf8f9'
  surface-dim: '#dcd9da'
  surface-bright: '#fcf8f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f4'
  surface-container: '#f0edee'
  surface-container-high: '#ebe7e8'
  surface-container-highest: '#e5e2e3'
  on-surface: '#1c1b1c'
  on-surface-variant: '#4d4635'
  inverse-surface: '#313031'
  inverse-on-surface: '#f3f0f1'
  outline: '#7f7663'
  outline-variant: '#d0c5af'
  surface-tint: '#735c00'
  primary: '#735c00'
  on-primary: '#ffffff'
  primary-container: '#d4af37'
  on-primary-container: '#554300'
  inverse-primary: '#e9c349'
  secondary: '#5f5e61'
  on-secondary: '#ffffff'
  secondary-container: '#e4e1e6'
  on-secondary-container: '#656467'
  tertiary: '#745b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#d2af48'
  on-tertiary-container: '#554300'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffe088'
  primary-fixed-dim: '#e9c349'
  on-primary-fixed: '#241a00'
  on-primary-fixed-variant: '#574500'
  secondary-fixed: '#e4e1e6'
  secondary-fixed-dim: '#c8c5ca'
  on-secondary-fixed: '#1b1b1e'
  on-secondary-fixed-variant: '#47464a'
  tertiary-fixed: '#ffe08b'
  tertiary-fixed-dim: '#e7c35a'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#584400'
  background: '#fcf8f9'
  on-background: '#1c1b1c'
  surface-variant: '#e5e2e3'
typography:
  headline-2xl:
    fontFamily: Playfair Display
    fontSize: 48px
    fontWeight: '600'
    lineHeight: 56px
  headline-xl:
    fontFamily: Playfair Display
    fontSize: 36px
    fontWeight: '600'
    lineHeight: 44px
  headline-xl-mobile:
    fontFamily: Playfair Display
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  headline-lg:
    fontFamily: Playfair Display
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md:
    fontFamily: Playfair Display
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 14px
  price-display:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system establishes a high-fashion digital salon bridging the bespoke world of heritage Place Vendôme fine jewelry with the cultural authority of contemporary hip-hop luxury. The brand caters to discerning collectors, tastemakers, and bespoke jewelry enthusiasts seeking custom precious metal and diamond dental artistry. 

The aesthetic is anchored in **Minimalist Luxury with Tactile Metallic Precision**:
- Deep, obsidian voids balanced with pristine ivory canvases to let product photography radiate with uncompromised luster.
- Architectural typographic tension: dramatic high-contrast serif editorial titles juxtaposed with surgical, Swiss-inspired sans-serif functional metadata.
- Deliberate restraint in decoration: no gratuitous gradients or synthetic drop shadows—depth is defined by micro-hairline borders, ambient champagne glows, and polished metallic tactile cues.
- Tactile prestige: micro-interactions evoke physical boutique experiences, from silky card presses to gold-leaf illuminated primary actions.

## Colors

The color palette reflects bespoke metallurgical alchemy, built on radiant yellow gold, rich velvety charcoals, deep onyx blacks, and warm champagne neutrals.

- **Primary (`#D4AF37`) & Metallic Accent (`#E5C158`)**: Emulates authentic 18K/24K yellow gold and micro-pave diamond brilliance. Reserved for primary purchase triggers, active indicators, luxury badges, and focal state highlights.
- **Secondary (`#18181B`) & Neutral Base (`#0B0B0C`)**: Charcoal and onyx foundations delivering uncompromising contrast, grounding editorial layouts and dark-mode hero moments.
- **Surface & Canvas (`#FFFFFF` & `#FDFBF7`)**: Warm ivory and clean gallery whites that evoke luxury showroom vitrines, allowing yellow gold, white gold, and rose gold pieces to display true-to-life tones without chromatic contamination.
- **Subtle Surface Containers (`#F4F4F5` / `#1C1C20`)**: Neutral, non-competing surfaces used for filter chips, category pills, and secondary background panels.
- **Border & Hairline (`#E4E4E7` in light, `#27272A` in dark)**: Razor-sharp 1px boundary definitions preserving structural clarity across all viewport densities.

## Typography

Typographic scale is structured around an editorial dialogue between high-contrast serifs and hyper-precise sans-serifs:

- **Display & Headlines (`Playfair Display`)**: Conveys classical jeweler craftsmanship, tailored authority, and editorial drama. Used strictly for hero welcome screens, high-tier collection banners, product detail titles, and primary category anchors.
- **Body & Structural Data (`Inter`)**: Engineered for effortless legibility across dense commerce specs (e.g., karat markings, diamond clarity specs, currency conversions, checkout flows).
- **Price & Metadata Hierarchy**: Prices command immediate recognition through semibold-to-bold sans-serif formatting, preventing optical interference with serif titles.
- **Letter Spacing**: Use `-0.02em` tracking on all `Playfair Display` headlines above 24px to enforce tight, magazine-cover poise. Apply `+0.04em` tracking to small uppercase labels (e.g., status badges, pill tags, navigation metadata).

## Layout & Spacing

The layout model is anchored on an 8pt modular system adapted for modern high-resolution mobile viewports:

- **Mobile Viewports (360px – 430px)**: 4-column fluid layout with `1.25rem` (20px) outer margins and `1rem` (16px) gutters between product listing columns.
- **Product Card Grids**: Strict 2-column format on mobile devices to preserve diamond pave detail and metal reflection fidelity. Vertical aspect ratio strictly maintained at `1:1.15` for product imagery containers.
- **Rhythm & Breathing Room**: Heavy vertical cadence separating distinct merchandising zones (`space-xl` / 32px between sections). Content cards maintain internal padding of `space-md` (16px) to avoid claustrophobic crowding near borders.
- **Touch Targets**: All interactive elements (navigation bar icons, quantity steppers, filter pills, favorite toggles) respect a minimum 44×44pt tap envelope.

## Elevation & Depth

Visual hierarchy uses low-contrast outlines paired with ambient champagne illumination:

- **Level 0 (Flat Ground)**: Base background surfaces (`#FFFFFF` in light mode, `#0B0B0C` in dark hero instances). No shadow, pure visual floor.
- **Level 1 (Cards & Tiles)**: Framed with a razor-thin `1px solid #F0F0F2` stroke. In dark contexts, uses `#27272A`. Elevation is created through surface contrast rather than murky drop shadows.
- **Level 2 (Floating Floating Bars & Bottom Sheets)**: Grounded by a delicate, diffuse shadow: `0px -4px 20px rgba(0, 0, 0, 0.04)` combined with an upper 1px hairline border.
- **Champagne Glow Trigger (Primary Call to Action)**: Primary CTA buttons utilize an ambient warm gold emission rather than heavy black drop shadows: `0px 8px 24px rgba(212, 175, 55, 0.28)`. This creates a tactile, illuminated presence on the page.

## Shapes

The shape system employs a deliberate tension between architectural rectangles and refined organic contours:

- **Product & Content Containers (`0.75rem` / 12px)**: Product showcases, category banners, and order summary cards use a controlled curvature that honors precision stone-setting.
- **Buttons & Chips (Pill / Full-Radius)**: Interactive triggers, filter selections, and status chips use full pill shapes (`9999px` / `rounded-full`) or smooth `0.75rem` rounded geometries, softening the hand-feel during navigation.
- **Image Frames**: Subtle 8px–12px radii with zero border overflow, framed by 1px inset or surface-level hairlines.

## Components

### Buttons
- **Primary Luxury Action**: Solid champagne gold fill (`#D4AF37` to `#E5C158`), black or rich charcoal text (`#0B0B0C`), weight 600, pill or 12px radius, with subtle ambient gold glow.
- **Secondary Boutique Action**: Crisp outline button featuring a 1.5px gold or dark charcoal stroke, transparent background, and high-contrast text.
- **Cart & Buy Dual Trigger**: Sticky bottom navigation container featuring a stacked or 50/50 split between filled Gold (Primary) and outlined Charcoal (Secondary).

### Chips & Filter Pills
- **State Selection**: Unselected chips utilize an ivory/neutral background (`#F4F4F5`) with muted text (`#71717A`). Selected chips transition to solid gold fill or dark charcoal with gold typography.
- **Category Navigators**: Horizontal sliding carousels with 32px height, uppercase `label-sm` typography, and tight 12px horizontal padding.

### Product Cards
- **Structure**: Clean 2-column cards consisting of a neutral, warm grey or soft ivory image container (`#F9F9FB`), topped with an unobtrusive heart-shaped wishlist icon button at the top-right.
- **Typography Stack**: Serif product title (`Playfair Display`, 14px, semibold), followed by a clean sans-serif price line (`Inter`, 15px, bold), with a secondary star rating line (`#D4AF37` icon with review count).

### Input Fields & Steppers
- **Text Inputs**: 48px height, 1px border stroke (`#E4E4E7`), warm off-white background, subtle gold highlight on focus state with no harsh browser rings.
- **Quantity Steppers**: Minimalist grouped capsule with `-` and `+` touch surfaces, separated by a crisp 1px vertical hairline, displaying bold numerical values centered.

### Order Status & Metal Badges
- **Purity Badges**: Micro-badges indicating `18K Gold`, `VS1 Diamonds`, or `Handcrafted` styled in soft gold-tinted translucent backgrounds (`rgba(212, 175, 55, 0.12)`) with crisp gold text.
- **Status Pills**: Muted pastels (Soft Gold for processing, Sage Emerald for delivered) bordered with 0.5px hairline precision.