
const DataNN = "ivan";
const DataPP = "1234";

const userInput = document.getElementById('nn');
const passInput = document.getElementById('pp');
const loginBtn = document.getElementById('log');
const origUserPlaceholder = userInput.placeholder || 'Enter your Username';
const origPassPlaceholder = passInput.placeholder || 'Enter your Password';

function validateForm(e){
   if(e && e.preventDefault) e.preventDefault();
   const username = (userInput.value || '').trim();
   const password = passInput.value || '';

   let ok = true;
   if(username !== DataNN){ markInvalid(userInput, 'Invalid Username'); ok = false; } else { clearInvalid(userInput, origUserPlaceholder); }
   if(password !== DataPP){ markInvalid(passInput, 'Invalid Password'); ok = false; } else { clearInvalid(passInput, origPassPlaceholder); }

   if(ok){
      alert('Login successful.');
   }
}



function markInvalid(input, message){
   if(!input) return;
   input.value = '';
   input.placeholder = message;
   input.classList.add('invalid');
}

function clearInvalid(input, originalPlaceholder){
   if(!input) return;
   input.classList.remove('invalid');
   input.placeholder = originalPlaceholder;
}
function meronBangLabelNN(){
    if (userInput.classList.contains('invalid')) {
        clearInvalid(userInput, origUserPlaceholder);
    }
}
function meronBangLabelPP(){
    if (passInput.classList.contains('invalid')) {
        clearInvalid(passInput, origPassPlaceholder);
    }
}

userInput.addEventListener('input',  meronBangLabelNN());

passInput.addEventListener('input',  meronBangLabelPP());

loginBtn.addEventListener('click', validateForm);


userInput.addEventListener('input', ()=>{ if((userInput.value||'').trim() === DataNN) hideLabel(userLabel); });
passInput.addEventListener('input', ()=>{ if((passInput.value||'') === DataPP) hideLabel(passLabel); });

loginBtn.addEventListener('click', validateForm);