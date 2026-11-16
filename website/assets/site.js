const root=document.documentElement;
const themeButton=document.querySelector('.theme-toggle');
try{if(localStorage.getItem('raptor-theme')==='light')root.classList.add('light')}catch{}
themeButton?.addEventListener('click',()=>{
  root.classList.toggle('light');
  try{localStorage.setItem('raptor-theme',root.classList.contains('light')?'light':'dark')}catch{}
});
const reduceMotion=window.matchMedia('(prefers-reduced-motion: reduce)').matches;
if(!reduceMotion&&'IntersectionObserver'in window){
  root.classList.add('js-motion');
  const targets=document.querySelectorAll('.feature-grid article,.compat>div,.status-panel>div,.status-panel>a,footer>*');
  targets.forEach((element,index)=>{
    element.classList.add('reveal');
    if(element.matches('.feature-grid article'))element.style.transitionDelay=`${(index%3)*75}ms`;
  });
  const observer=new IntersectionObserver((entries)=>{
    entries.forEach(entry=>{
      if(entry.isIntersecting){
        entry.target.classList.add('is-visible');
        observer.unobserve(entry.target);
      }
    });
  },{threshold:.14,rootMargin:'0px 0px -36px 0px'});
  targets.forEach(element=>observer.observe(element));
}
