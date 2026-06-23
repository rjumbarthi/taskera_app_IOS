function toggleSGrp(el){el.closest('.sgrp').classList.toggle('open');}

function organizeSettingsGroups(){
  const content=document.querySelector('#p-settings .content');
  if(!content)return;
  moveAccountGroupToProfile();
  moveWidgetPreviewToDisplay();
  const features=ensureFeaturesTabsGroup();
  const card=features.querySelector('.set-card');
  ['f-habits','f-calendar','f-notes','f-inbox','f-focusToday','f-focusPeak','f-focusTimer','f-focusBrainDump'].forEach(id=>{
    const row=document.getElementById(id)?.closest('.set-row');
    if(row&&card&&!card.contains(row))card.appendChild(row);
  });
  if(!features.parentElement)content.appendChild(features);
  // Merge Smart Features rows into Features & Tabs
  const ai=getSettingsGroup('AI & Smart features')||getSettingsGroup('Smart Features');
  if(ai){
    const card=features.querySelector('.set-card');
    const aiCard=ai.querySelector('.set-card');
    if(card&&aiCard){
      Array.from(aiCard.querySelectorAll('.set-row')).forEach(row=>card.appendChild(row));
    }
    // Move any direct set-rows from ai sgrp-body
    const aiBody=ai.querySelector('.sgrp-body');
    if(aiBody&&card){
      Array.from(aiBody.querySelectorAll('.set-row')).forEach(row=>card.appendChild(row));
    }
    ai.remove();
  }
  // Rename the combined group
  const ft=features.querySelector('.sgrp-title');
  if(ft)ft.textContent='Features, Tabs & Smart';
  const order=['Kaal Pro','Display','Tasks','Features, Tabs & Smart','Calendar & Inbox','Integrations','Sync & Data','Account','Notifications'];
  order.forEach(title=>{
    const g=getSettingsGroup(title);
    if(g)content.appendChild(g);
  });
}

function moveAccountGroupToProfile(){
  const profileContent=document.querySelector('#p-profile .content');
  if(!profileContent)return;
  const account=Array.from(document.querySelectorAll('.sgrp')).find(g=>{
    const t=g.querySelector('.sgrp-title');
    return t&&t.textContent.trim()==='Account';
  });
  if(account&&account.parentElement!==profileContent)profileContent.appendChild(account);
}

function moveWidgetPreviewToDisplay(){
  const display=getSettingsGroup('Display');
  if(!display)return;
  const displayCard=display.querySelector('.set-card');
  if(!displayCard)return;
  const rows=Array.from(document.querySelectorAll('#p-settings .set-row')).filter(row=>{
    const label=row.querySelector('.set-lbl');
    return label&&label.textContent.trim()==='Widget preview';
  });
  if(!rows.length)return;
  const target=rows.find(row=>display.contains(row))||rows[0];
  if(!display.contains(target))displayCard.appendChild(target);
  target.setAttribute('onclick',"nav('widget')");
  target.style.cursor='pointer';
  rows.forEach(row=>{if(row!==target)row.remove();});
}

function ensureFeaturesTabsGroup(){
  let g=document.getElementById('settings-features-tabs-group');
  if(g)return g;
  g=document.createElement('div');
  g.className='sgrp';
  g.id='settings-features-tabs-group';
  g.innerHTML='<div class="sgrp-hdr" onclick="toggleSGrp(this)"><div class="sgrp-ico" style="background:rgba(10,132,255,.12)"><svg width="13" height="13" viewBox="0 0 22 22" fill="none" stroke="var(--acc2)" stroke-width="1.6" stroke-linecap="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="12" y="3" width="7" height="7" rx="1"/><rect x="3" y="12" width="7" height="7" rx="1"/><rect x="12" y="12" width="7" height="7" rx="1"/></svg></div><div class="sgrp-title">Features &amp; Tabs</div><div class="sgrp-chev">›</div></div><div class="sgrp-body"><div style="padding:0 12px 8px"><div class="set-card"></div></div></div>';
  return g;
}

function getSettingsGroup(title){
  return Array.from(document.querySelectorAll('#p-settings .content > .sgrp')).find(g=>{
    const t=g.querySelector('.sgrp-title');
    return t&&t.textContent.trim()===title;
  });
}


// Bootstrap script for per-screen HTML files.
// Runs once on load to expand collapsible groups in Settings,
// move Account group to Profile, etc.
window.addEventListener('DOMContentLoaded', () => {
  setTimeout(() => {
    try {
      if (typeof organizeSettingsGroups === 'function' && document.getElementById('p-settings')) {
        organizeSettingsGroups();
      }
      if (typeof moveAccountGroupToProfile === 'function' && document.getElementById('p-profile')) {
        moveAccountGroupToProfile();
      }
    } catch(e) { console.warn('init err', e); }
  }, 50);
});
