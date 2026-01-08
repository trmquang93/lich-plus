/**
 * Lich Viet Landing Page JavaScript
 */

(function() {
    'use strict';

    // ==========================================================================
    // DOM Elements
    // ==========================================================================

    const nav = document.getElementById('nav');
    const navToggle = document.getElementById('navToggle');
    const mobileMenu = document.getElementById('mobileMenu');
    const solarDateEl = document.getElementById('solarDate');
    const lunarDayEl = document.getElementById('lunarDay');
    const lunarCanChiEl = document.getElementById('lunarCanChi');

    // ==========================================================================
    // Vietnamese Lunar Calendar Data
    // ==========================================================================

    const CAN = ['Giap', 'At', 'Binh', 'Dinh', 'Mau', 'Ky', 'Canh', 'Tan', 'Nham', 'Quy'];
    const CHI = ['Ty', 'Suu', 'Dan', 'Mao', 'Thin', 'Ti', 'Ngo', 'Mui', 'Than', 'Dau', 'Tuat', 'Hoi'];

    const MONTH_NAMES = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
    ];

    const WEEKDAY_NAMES = [
        'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
    ];

    // ==========================================================================
    // Lunar Calendar Calculations
    // ==========================================================================

    /**
     * Convert Julian day to lunar date
     * Based on Ho Ngoc Duc's algorithm
     */
    function jdToDate(jd) {
        const z = Math.floor(jd + 0.5);
        const a = Math.floor((z - 1867216.25) / 36524.25);
        const aa = z + 1 + a - Math.floor(a / 4);
        const b = aa + 1524;
        const c = Math.floor((b - 122.1) / 365.25);
        const d = Math.floor(365.25 * c);
        const e = Math.floor((b - d) / 30.6001);
        const day = b - d - Math.floor(30.6001 * e);
        const month = e < 14 ? e - 1 : e - 13;
        const year = month > 2 ? c - 4716 : c - 4715;
        return { day, month, year };
    }

    /**
     * Convert solar date to Julian day number
     */
    function jdFromDate(day, month, year) {
        const a = Math.floor((14 - month) / 12);
        const y = year + 4800 - a;
        const m = month + 12 * a - 3;
        let jd = day + Math.floor((153 * m + 2) / 5) + 365 * y + Math.floor(y / 4) - Math.floor(y / 100) + Math.floor(y / 400) - 32045;
        if (jd < 2299161) {
            jd = day + Math.floor((153 * m + 2) / 5) + 365 * y + Math.floor(y / 4) - 32083;
        }
        return jd;
    }

    /**
     * Get new moon day
     */
    function getNewMoonDay(k, timeZone) {
        const T = k / 1236.85;
        const T2 = T * T;
        const T3 = T2 * T;
        const dr = Math.PI / 180;
        let Jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * T2 - 0.000000155 * T3;
        Jd1 = Jd1 + 0.00033 * Math.sin((166.56 + 132.87 * T - 0.009173 * T2) * dr);
        const M = 359.2242 + 29.10535608 * k - 0.0000333 * T2 - 0.00000347 * T3;
        const Mpr = 306.0253 + 385.81691806 * k + 0.0107306 * T2 + 0.00001236 * T3;
        const F = 21.2964 + 390.67050646 * k - 0.0016528 * T2 - 0.00000239 * T3;
        let C1 = (0.1734 - 0.000393 * T) * Math.sin(M * dr) + 0.0021 * Math.sin(2 * dr * M);
        C1 = C1 - 0.4068 * Math.sin(Mpr * dr) + 0.0161 * Math.sin(dr * 2 * Mpr);
        C1 = C1 - 0.0004 * Math.sin(dr * 3 * Mpr);
        C1 = C1 + 0.0104 * Math.sin(dr * 2 * F) - 0.0051 * Math.sin(dr * (M + Mpr));
        C1 = C1 - 0.0074 * Math.sin(dr * (M - Mpr)) + 0.0004 * Math.sin(dr * (2 * F + M));
        C1 = C1 - 0.0004 * Math.sin(dr * (2 * F - M)) - 0.0006 * Math.sin(dr * (2 * F + Mpr));
        C1 = C1 + 0.0010 * Math.sin(dr * (2 * F - Mpr)) + 0.0005 * Math.sin(dr * (2 * Mpr + M));
        let deltat;
        if (T < -11) {
            deltat = 0.001 + 0.000839 * T + 0.0002261 * T2 - 0.00000845 * T3 - 0.000000081 * T * T3;
        } else {
            deltat = -0.000278 + 0.000265 * T + 0.000262 * T2;
        }
        const JdNew = Jd1 + C1 - deltat;
        return Math.floor(JdNew + 0.5 + timeZone / 24);
    }

    /**
     * Get sun longitude at a given Julian day
     */
    function getSunLongitude(jdn, timeZone) {
        const T = (jdn - 2451545.5 - timeZone / 24) / 36525;
        const T2 = T * T;
        const dr = Math.PI / 180;
        const M = 357.52910 + 35999.05030 * T - 0.0001559 * T2 - 0.00000048 * T * T2;
        const L0 = 280.46645 + 36000.76983 * T + 0.0003032 * T2;
        let DL = (1.914600 - 0.004817 * T - 0.000014 * T2) * Math.sin(dr * M);
        DL = DL + (0.019993 - 0.000101 * T) * Math.sin(dr * 2 * M) + 0.000290 * Math.sin(dr * 3 * M);
        let L = L0 + DL;
        L = L * dr;
        L = L - Math.PI * 2 * (Math.floor(L / (Math.PI * 2)));
        return Math.floor(L / Math.PI * 6);
    }

    /**
     * Get lunar month 11 of a year
     */
    function getLunarMonth11(yy, timeZone) {
        const off = jdFromDate(31, 12, yy) - 2415021;
        const k = Math.floor(off / 29.530588853);
        let nm = getNewMoonDay(k, timeZone);
        const sunLong = getSunLongitude(nm, timeZone);
        if (sunLong >= 9) {
            nm = getNewMoonDay(k - 1, timeZone);
        }
        return nm;
    }

    /**
     * Get leap month offset
     */
    function getLeapMonthOffset(a11, timeZone) {
        const k = Math.floor((a11 - 2415021.076998695) / 29.530588853 + 0.5);
        let last;
        let i = 1;
        let arc = getSunLongitude(getNewMoonDay(k + i, timeZone), timeZone);
        do {
            last = arc;
            i++;
            arc = getSunLongitude(getNewMoonDay(k + i, timeZone), timeZone);
        } while (arc !== last && i < 14);
        return i - 1;
    }

    /**
     * Convert solar date to lunar date
     */
    function solarToLunar(day, month, year, timeZone) {
        const dayNumber = jdFromDate(day, month, year);
        const k = Math.floor((dayNumber - 2415021.076998695) / 29.530588853);
        let monthStart = getNewMoonDay(k + 1, timeZone);
        if (monthStart > dayNumber) {
            monthStart = getNewMoonDay(k, timeZone);
        }
        let a11 = getLunarMonth11(year, timeZone);
        let b11 = a11;
        let lunarYear;
        if (a11 >= monthStart) {
            lunarYear = year;
            a11 = getLunarMonth11(year - 1, timeZone);
        } else {
            lunarYear = year + 1;
            b11 = getLunarMonth11(year + 1, timeZone);
        }
        const lunarDay = dayNumber - monthStart + 1;
        const diff = Math.floor((monthStart - a11) / 29);
        let lunarLeap = 0;
        let lunarMonth = diff + 11;
        if (b11 - a11 > 365) {
            const leapMonthDiff = getLeapMonthOffset(a11, timeZone);
            if (diff >= leapMonthDiff) {
                lunarMonth = diff + 10;
                if (diff === leapMonthDiff) {
                    lunarLeap = 1;
                }
            }
        }
        if (lunarMonth > 12) {
            lunarMonth = lunarMonth - 12;
        }
        if (lunarMonth >= 11 && diff < 4) {
            lunarYear -= 1;
        }
        return {
            day: lunarDay,
            month: lunarMonth,
            year: lunarYear,
            leap: lunarLeap
        };
    }

    /**
     * Get Can Chi for a lunar year
     */
    function getCanChiYear(year) {
        const can = CAN[(year + 6) % 10];
        const chi = CHI[(year + 8) % 12];
        return can + ' ' + chi;
    }

    /**
     * Get Can Chi for day
     */
    function getCanChiDay(jd) {
        const can = CAN[(jd + 9) % 10];
        const chi = CHI[(jd + 1) % 12];
        return can + ' ' + chi;
    }

    // ==========================================================================
    // Display Functions
    // ==========================================================================

    /**
     * Update lunar date display
     */
    function updateLunarDate() {
        const now = new Date();
        const day = now.getDate();
        const month = now.getMonth() + 1;
        const year = now.getFullYear();
        const weekday = now.getDay();

        // Solar date
        const solarStr = `${WEEKDAY_NAMES[weekday]}, ${MONTH_NAMES[month - 1]} ${day}, ${year}`;
        if (solarDateEl) {
            solarDateEl.textContent = solarStr;
        }

        // Lunar date
        const timeZone = 7; // Vietnam timezone (UTC+7)
        const lunar = solarToLunar(day, month, year, timeZone);
        const lunarStr = `${lunar.day}/${lunar.month}${lunar.leap ? ' (leap)' : ''} Lunar`;
        if (lunarDayEl) {
            lunarDayEl.textContent = lunarStr;
        }

        // Can Chi
        const jd = jdFromDate(day, month, year);
        const canChiDay = getCanChiDay(jd);
        const canChiYear = getCanChiYear(lunar.year);
        if (lunarCanChiEl) {
            lunarCanChiEl.textContent = `${canChiDay} - Year of ${canChiYear}`;
        }
    }

    // ==========================================================================
    // Navigation
    // ==========================================================================

    /**
     * Toggle mobile menu
     */
    function toggleMobileMenu() {
        navToggle.classList.toggle('active');
        mobileMenu.classList.toggle('active');
    }

    /**
     * Close mobile menu
     */
    function closeMobileMenu() {
        navToggle.classList.remove('active');
        mobileMenu.classList.remove('active');
    }

    /**
     * Handle scroll for nav styling
     */
    function handleScroll() {
        if (window.scrollY > 50) {
            nav.classList.add('scrolled');
        } else {
            nav.classList.remove('scrolled');
        }
    }

    // ==========================================================================
    // Smooth Scrolling
    // ==========================================================================

    /**
     * Smooth scroll to element
     */
    function smoothScrollTo(target) {
        const element = document.querySelector(target);
        if (element) {
            const navHeight = nav.offsetHeight;
            const elementPosition = element.getBoundingClientRect().top + window.pageYOffset;
            const offsetPosition = elementPosition - navHeight;

            window.scrollTo({
                top: offsetPosition,
                behavior: 'smooth'
            });
        }
    }

    /**
     * Handle anchor clicks
     */
    function handleAnchorClick(e) {
        const href = e.currentTarget.getAttribute('href');
        if (href && href.startsWith('#')) {
            e.preventDefault();
            smoothScrollTo(href);
            closeMobileMenu();
        }
    }

    // ==========================================================================
    // Scroll Animations (AOS-like)
    // ==========================================================================

    /**
     * Check if element is in viewport
     */
    function isInViewport(element) {
        const rect = element.getBoundingClientRect();
        return (
            rect.top <= (window.innerHeight || document.documentElement.clientHeight) * 0.85
        );
    }

    /**
     * Animate elements on scroll
     */
    function animateOnScroll() {
        const elements = document.querySelectorAll('[data-aos]');
        elements.forEach(element => {
            if (isInViewport(element)) {
                const delay = element.getAttribute('data-aos-delay') || 0;
                setTimeout(() => {
                    element.classList.add('aos-animate');
                }, delay);
            }
        });
    }

    // ==========================================================================
    // Event Listeners
    // ==========================================================================

    function initEventListeners() {
        // Mobile menu toggle
        if (navToggle) {
            navToggle.addEventListener('click', toggleMobileMenu);
        }

        // Close mobile menu on link click
        const mobileLinks = document.querySelectorAll('.mobile-menu-link');
        mobileLinks.forEach(link => {
            link.addEventListener('click', handleAnchorClick);
        });

        // Smooth scroll for all anchor links
        const anchorLinks = document.querySelectorAll('a[href^="#"]');
        anchorLinks.forEach(link => {
            link.addEventListener('click', handleAnchorClick);
        });

        // Scroll events
        window.addEventListener('scroll', () => {
            handleScroll();
            animateOnScroll();
        }, { passive: true });

        // Initial calls
        handleScroll();
        animateOnScroll();
    }

    // ==========================================================================
    // Initialize
    // ==========================================================================

    function init() {
        updateLunarDate();
        initEventListeners();

        // Update lunar date every minute
        setInterval(updateLunarDate, 60000);
    }

    // Run on DOM ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
