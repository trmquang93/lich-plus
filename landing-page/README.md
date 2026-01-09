# Lich Viet Landing Page

A modern, responsive landing page for the Lich Viet Vietnamese calendar iOS app.

## Features

- Responsive design (mobile, tablet, desktop)
- Live lunar date display with Can-Chi notation
- Smooth scroll navigation
- Scroll-based animations
- Vietnamese design system colors

## File Structure

```
landing-page/
├── index.html          # Main HTML file
├── css/
│   └── styles.css      # All styles
├── js/
│   └── main.js         # JavaScript functionality
├── images/             # Screenshot and asset storage
│   └── .gitkeep
└── README.md
```

## Local Development

Simply open `index.html` in a web browser. No build step required.

For local development with live reload, you can use any simple HTTP server:

```bash
# Python 3
python -m http.server 8000

# Node.js (npx)
npx serve

# PHP
php -S localhost:8000
```

Then open `http://localhost:8000` in your browser.

## Adding Screenshots

1. Export app screenshots from Simulator or device
2. Save them to the `images/` folder with descriptive names:
   - `screenshot-calendar.png` - Main calendar view
   - `screenshot-timeline.png` - Timeline/events view
   - `screenshot-day-detail.png` - Day detail with astrology
3. Update image references in `index.html`

### Recommended Screenshot Sizes

- Hero phone mockup: 320x640px (2x for retina)
- Preview cards: 800x600px (main), 400x300px (side)
- OG image: 1200x630px

## Customization

### Colors (in styles.css)

The design system colors match the iOS app:

```css
--color-primary: #C7251D;        /* Vietnamese red */
--color-primary-dark: #A91C15;   /* Hover state */
--color-accent-green: #4CAF50;   /* Positive actions */
--color-hoang-dao-gold: #D4AF37; /* Auspicious hours */
```

### Adding App Store Link

Replace the placeholder `href="#"` in the download button:

```html
<a href="https://apps.apple.com/app/id123456789" class="app-store-btn">
```

### Adding QR Code

Replace the SVG placeholder in the download section with an actual QR code image linking to the App Store.

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers (iOS Safari, Chrome Android)

## Performance

- No external CSS/JS dependencies (except Google Fonts)
- Single CSS file with CSS custom properties
- Vanilla JavaScript (no framework)
- Lazy loading ready for images

## Deployment

This is a static site. Deploy to any static hosting:

- GitHub Pages
- Netlify
- Vercel
- Firebase Hosting
- AWS S3 + CloudFront

### GitHub Pages

1. Push to a `gh-pages` branch or configure in repository settings
2. Site will be available at `https://username.github.io/repo-name/landing-page/`

### Netlify/Vercel

1. Connect repository
2. Set build directory to `landing-page/`
3. Deploy automatically on push
