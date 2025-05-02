/**
 * AWS Basics Demo - Main JavaScript
 */

document.addEventListener('DOMContentLoaded', () => {
    // Mobile navigation toggle
    const hamburger = document.querySelector('.hamburger');
    const navLinks = document.querySelector('.nav-links');
    
    if (hamburger) {
        hamburger.addEventListener('click', () => {
            navLinks.classList.toggle('active');
            hamburger.classList.toggle('active');
        });
    }
    
    // Service icon animation
    const serviceIcons = document.querySelectorAll('.service-icon');
    
    serviceIcons.forEach(icon => {
        // Add random subtle movement to icons
        setInterval(() => {
            const xMove = (Math.random() - 0.5) * 10;
            const yMove = (Math.random() - 0.5) * 10;
            
            icon.style.transform = `translate(${xMove}px, ${yMove}px)`;
            
            setTimeout(() => {
                icon.style.transform = 'translate(0, 0)';
            }, 500);
        }, Math.random() * 5000 + 3000); // Random interval between 3-8 seconds
    });
    
    // Intersection Observer for scroll animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);
    
    // Observe all cards and sections for scroll animations
    document.querySelectorAll('.card, section').forEach(el => {
        observer.observe(el);
    });
    
    // Add active class to current nav link based on URL
    const currentPage = window.location.pathname.split('/').pop();
    const navLinksList = document.querySelectorAll('.nav-links a');
    
    navLinksList.forEach(link => {
        const linkPage = link.getAttribute('href').split('/').pop();
        
        if ((currentPage === '' && link.getAttribute('href') === '#') || 
            (linkPage === currentPage)) {
            link.classList.add('active');
        } else {
            link.classList.remove('active');
        }
    });
    
    // AWS Service Tooltip Information
    const serviceInfo = {
        's3-icon': {
            title: 'Amazon S3',
            description: 'Simple Storage Service for object storage',
            link: 'pages/static-website.html'
        },
        'cloudfront-icon': {
            title: 'Amazon CloudFront',
            description: 'Content Delivery Network for global distribution',
            link: 'pages/static-website.html'
        },
        'ec2-icon': {
            title: 'Amazon EC2',
            description: 'Elastic Compute Cloud for virtual servers',
            link: 'pages/ec2-instance.html'
        },
        'route53-icon': {
            title: 'Amazon Route 53',
            description: 'Domain Name System (DNS) web service',
            link: '#'
        }
    };
    
    // Create tooltips for service icons
    serviceIcons.forEach(icon => {
        const iconId = icon.id;
        const info = serviceInfo[iconId];
        
        if (info) {
            // Create tooltip element
            const tooltip = document.createElement('div');
            tooltip.className = 'service-tooltip';
            tooltip.innerHTML = `
                <h4>${info.title}</h4>
                <p>${info.description}</p>
                ${info.link !== '#' ? `<a href="${info.link}">Learn more →</a>` : ''}
            `;
            
            // Add tooltip to icon
            icon.appendChild(tooltip);
            
            // Show/hide tooltip on hover
            icon.addEventListener('mouseenter', () => {
                tooltip.style.opacity = '1';
                tooltip.style.transform = 'translateY(0)';
            });
            
            icon.addEventListener('mouseleave', () => {
                tooltip.style.opacity = '0';
                tooltip.style.transform = 'translateY(10px)';
            });
        }
    });
    
    // Add CSS for tooltips
    const style = document.createElement('style');
    style.textContent = `
        .service-tooltip {
            position: absolute;
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%) translateY(10px);
            background-color: white;
            color: #232F3E;
            padding: 10px;
            border-radius: 4px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            width: 200px;
            opacity: 0;
            transition: opacity 0.3s, transform 0.3s;
            pointer-events: none;
            z-index: 100;
            text-align: center;
        }
        
        .service-tooltip:after {
            content: '';
            position: absolute;
            top: 100%;
            left: 50%;
            margin-left: -8px;
            width: 0;
            height: 0;
            border-left: 8px solid transparent;
            border-right: 8px solid transparent;
            border-top: 8px solid white;
        }
        
        .service-tooltip h4 {
            margin: 0 0 5px;
            color: #232F3E;
        }
        
        .service-tooltip p {
            margin: 0 0 8px;
            font-size: 0.8rem;
        }
        
        .service-tooltip a {
            color: #FF9900;
            font-size: 0.8rem;
            font-weight: 600;
        }
        
        /* Animation classes */
        .card, section {
            opacity: 0;
            transform: translateY(20px);
            transition: opacity 0.6s, transform 0.6s;
        }
        
        .card.animate, section.animate {
            opacity: 1;
            transform: translateY(0);
        }
        
        /* Mobile nav styles */
        @media (max-width: 768px) {
            .nav-links {
                position: fixed;
                top: 60px;
                left: 0;
                right: 0;
                background-color: #232F3E;
                flex-direction: column;
                padding: 20px;
                transform: translateY(-100%);
                opacity: 0;
                transition: transform 0.3s, opacity 0.3s;
            }
            
            .nav-links.active {
                transform: translateY(0);
                opacity: 1;
            }
            
            .hamburger.active .bar:nth-child(1) {
                transform: rotate(45deg) translate(5px, 6px);
            }
            
            .hamburger.active .bar:nth-child(2) {
                opacity: 0;
            }
            
            .hamburger.active .bar:nth-child(3) {
                transform: rotate(-45deg) translate(5px, -6px);
            }
        }
    `;
    
    document.head.appendChild(style);
});
