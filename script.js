// ==========================
// KRB SCRIPT.JS
// ==========================

// ظهور العناصر عند النزول

const observer = new IntersectionObserver((entries)=>{

entries.forEach(entry=>{

if(entry.isIntersecting){

entry.target.style.opacity="1";
entry.target.style.transform="translateY(0)";

}

});

},{threshold:.15});

document.querySelectorAll(".card,.stat,.community,.title").forEach(el=>{

el.style.opacity="0";

el.style.transform="translateY(60px)";

el.style.transition=".8s ease";

observer.observe(el);

});

// تأثير البار عند النزول

const navbar=document.querySelector(".navbar");

window.addEventListener("scroll",()=>{

if(window.scrollY>50){

navbar.style.background="rgba(10,10,20,.75)";
navbar.style.boxShadow="0 15px 40px rgba(0,0,0,.35)";
navbar.style.backdropFilter="blur(25px)";

}else{

navbar.style.background="rgba(255,255,255,.05)";
navbar.style.boxShadow="none";

}

});

// تحريك الخلفية مع الماوس

document.addEventListener("mousemove",(e)=>{

const x=(e.clientX/window.innerWidth)*30;

const y=(e.clientY/window.innerHeight)*30;

document.querySelectorAll(".blob").forEach((blob,index)=>{

blob.style.transform=`translate(${x*(index+1)/4}px,${y*(index+1)/4}px)`;

});

});

// تأثير ضغط الأزرار

document.querySelectorAll(".btn,.download").forEach(btn=>{

btn.addEventListener("mousedown",()=>{

btn.style.transform="scale(.95)";

});

btn.addEventListener("mouseup",()=>{

btn.style.transform="";

});

btn.addEventListener("mouseleave",()=>{

btn.style.transform="";

});

});

// سنة الفوتر تلقائياً

const footer=document.querySelector("footer");

footer.innerHTML=`© ${new Date().getFullYear()} KRB — جميع الحقوق محفوظة`;

// تحميل الصفحة

window.addEventListener("load",()=>{

document.body.style.opacity="1";

});

document.body.style.opacity="0";
document.body.style.transition=".8s";
