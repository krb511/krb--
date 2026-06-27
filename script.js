/**
 * KRB | Premium Interaction Engine
 * تأثيرات سلسة ومحسنة للأداء
 */
(function() {
    'use strict';

    // ========== تأثير توهج الماوس ==========
    const mouseGlow = document.getElementById('mouseGlow');
    let mouseX = 0;
    let mouseY = 0;
    let currentX = 0;
    let currentY = 0;
    let rafId = null;

    // استخدام requestAnimationFrame لأداء سلس
    function updateGlowPosition() {
        const dx = mouseX - currentX;
        const dy = mouseY - currentY;
        
        // حركة تأخيرية ناعمة (lerp)
        currentX += dx * 0.08;
        currentY += dy * 0.08;
        
        if (mouseGlow) {
            mouseGlow.style.left = currentX + 'px';
            mouseGlow.style.top = currentY + 'px';
        }
        
        rafId = requestAnimationFrame(updateGlowPosition);
    }

    // بدء الحلقة عند تحريك الماوس فقط لتوفير الأداء
    function startGlowLoop() {
        if (!rafId) {
            rafId = requestAnimationFrame(updateGlowPosition);
        }
    }

    function stopGlowLoop() {
        if (rafId) {
            cancelAnimationFrame(rafId);
            rafId = null;
        }
    }

    // مستمع حركة الماوس مع debounce طبيعي
    document.addEventListener('mousemove', function(e) {
        mouseX = e.clientX;
        mouseY = e.clientY;
        
        if (mouseGlow && !mouseGlow.classList.contains('active')) {
            mouseGlow.classList.add('active');
        }
        startGlowLoop();
    }, { passive: true });

    // إخفاء التوهج عند مغادرة النافذة
    document.addEventListener('mouseleave', function() {
        if (mouseGlow) {
            mouseGlow.classList.remove('active');
        }
        stopGlowLoop();
    });

    // إظهار مجدد عند العودة
    document.addEventListener('mouseenter', function() {
        if (mouseGlow) {
            mouseGlow.classList.add('active');
        }
        startGlowLoop();
    });

    // ========== تأثيرات التفاعل مع بطاقات التحميل ==========
    const downloadCards = document.querySelectorAll('.download-card');
    
    downloadCards.forEach(function(card) {
        // تأثير ضغط عند النقر
        card.addEventListener('mousedown', function() {
            this.style.transform = 'scale(0.97)';
            this.style.transition = 'transform 0.1s ease';
        });

        card.addEventListener('mouseup', function() {
            this.style.transform = '';
            this.style.transition = 'all 0.4s cubic-bezier(0.16, 1, 0.3, 1)';
        });

        card.addEventListener('mouseleave', function() {
            this.style.transform = '';
            this.style.transition = 'all 0.4s cubic-bezier(0.16, 1, 0.3, 1)';
        });

        // تأثير تتبع الماوس داخل البطاقة للتوهج
        card.addEventListener('mousemove', function(e) {
            const rect = this.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            const glowElement = this.querySelector('.card-glow');
            if (glowElement) {
                const centerX = (x / rect.width) * 100;
                const centerY = (y / rect.height) * 100;
                glowElement.style.background = 
                    `radial-gradient(circle at ${centerX}% ${centerY}%, var(--brand-primary) 0%, transparent 70%)`;
            }
        });

        // إعادة تعيين التوهج عند الخروج
        card.addEventListener('mouseleave', function() {
            const glowElement = this.querySelector('.card-glow');
            if (glowElement) {
                glowElement.style.background = '';
            }
        });
    });

    // ========== تأثيرات التمرير (Scroll) ==========
    // مراقب Intersection Observer للعناصر التي تظهر أثناء التمرير
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(function(entry) {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    // مراقبة البطاقات
    downloadCards.forEach(function(card) {
        card.style.opacity = '1';
        card.style.transform = 'translateY(0)';
    });

    // ========== شريط التنقل - تأثير التمرير ==========
    const navbar = document.querySelector('.navbar');
    let lastScrollY = window.scrollY;
    let scrollTimeout;

    window.addEventListener('scroll', function() {
        const currentScrollY = window.scrollY;
        
        if (navbar) {
            if (currentScrollY > 100) {
                navbar.style.background = 'rgba(10, 10, 15, 0.7)';
                navbar.style.backdropFilter = 'blur(24px) saturate(180%)';
                navbar.style.webkitBackdropFilter = 'blur(24px) saturate(180%)';
            } else {
                navbar.style.background = '';
                navbar.style.backdropFilter = '';
                navbar.style.webkitBackdropFilter = '';
            }
        }
        
        lastScrollY = currentScrollY;
        
        // إيقاف حلقة التوهج أثناء التمرير لتوفير الأداء
        stopGlowLoop();
        clearTimeout(scrollTimeout);
        scrollTimeout = setTimeout(function() {
            if (document.hasFocus()) {
                startGlowLoop();
            }
        }, 150);
    }, { passive: true });

    // ========== زر القائمة للجوال ==========
    const menuToggle = document.getElementById('menuToggle');
    const navLinks = document.querySelector('.nav-links');
    
    if (menuToggle && navLinks) {
        menuToggle.addEventListener('click', function() {
            const isVisible = navLinks.style.display === 'flex';
            
            if (isVisible) {
                navLinks.style.display = 'none';
                this.innerHTML = '<i class="fa-solid fa-bars"></i>';
            } else {
                navLinks.style.display = 'flex';
                navLinks.style.position = 'absolute';
                navLinks.style.top = '100%';
                navLinks.style.left = '0';
                navLinks.style.right = '0';
                navLinks.style.marginTop = '12px';
                navLinks.style.padding = '8px';
                navLinks.style.background = 'rgba(10, 10, 15, 0.9)';
                navLinks.style.backdropFilter = 'blur(24px)';
                navLinks.style.webkitBackdropFilter = 'blur(24px)';
                navLinks.style.border = '1px solid rgba(255, 255, 255, 0.08)';
                navLinks.style.borderRadius = '20px';
                navLinks.style.flexDirection = 'column';
                navLinks.style.alignItems = 'center';
                navLinks.style.gap = '4px';
                navLinks.style.zIndex = '99';
                this.innerHTML = '<i class="fa-solid fa-xmark"></i>';
            }
        });

        // إغلاق القائمة عند النقر على رابط
        navLinks.querySelectorAll('.nav-link').forEach(function(link) {
            link.addEventListener('click', function() {
                navLinks.style.display = 'none';
                menuToggle.innerHTML = '<i class="fa-solid fa-bars"></i>';
            });
        });
    }

    // ========== تحسين الوصول ==========
    // دعم التنقل بلوحة المفاتيح
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && navLinks && navLinks.style.display === 'flex') {
            navLinks.style.display = 'none';
            if (menuToggle) {
                menuToggle.innerHTML = '<i class="fa-solid fa-bars"></i>';
            }
        }
    });

    // ========== إدارة التركيز والبطارية ==========
    // إيقاف الحلقات عندما تكون الصفحة غير مرئية
    document.addEventListener('visibilitychange', function() {
        if (document.hidden) {
            stopGlowLoop();
        } else {
            startGlowLoop();
        }
    });

    // ========== تسجيل الأخطاء بصمت ==========
    window.addEventListener('error', function(e) {
        // في بيئة الإنتاج، يمكن إرسال الأخطاء إلى خدمة مراقبة
        if (console && console.debug) {
            console.debug('KRB: خطأ غير حرج -', e.message);
        }
    });

    // بدء تشغيل التطبيق
    console.log('%c KRB %c v2.0 ',
        'background: #6c5ce7; color: white; padding: 4px 8px; border-radius: 4px 0 0 4px; font-weight: bold;',
        'background: #0a0a0f; color: #a0a0b5; padding: 4px 8px; border-radius: 0 4px 4px 0;');
})();
