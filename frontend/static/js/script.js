function showAlert(message) {
    document.getElementById('alertMessage').innerText = message;
    document.getElementById('customAlert').style.display = 'block';
}

function closeAlert() {
    document.getElementById('customAlert').style.display = 'none';
}

document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('dataForm');

    form.addEventListener('submit', (event) => {
        const dobInput = document.getElementById('dob');
        const dob = new Date(dobInput.value);
        const today = new Date();

        const ageDiffMs = today - dob;
        const ageDate = new Date(ageDiffMs);
        const age = Math.abs(ageDate.getUTCFullYear() - 1970);

        if (dob > today) {
            showAlert('Please enter a valid date of birth. Future dates are not allowed.');
            event.preventDefault(); // Prevent form submission
            return;
        }

        if (age < 10) {
            showAlert('Please enter a valid date of birth. You must be at least 10 years old.');
            event.preventDefault(); // Prevent form submission
            return;
        }
    });
});























// document.addEventListener('DOMContentLoaded', () => {
//     const form = document.getElementById('dataForm');

//     form.addEventListener('submit', (event) => {
//         const dobInput = document.getElementById('dob');
//         const dob = new Date(dobInput.value);
//         const today = new Date();

//         const ageDiffMs = today - dob;
//         const ageDate = new Date(ageDiffMs);
//         const age = Math.abs(ageDate.getUTCFullYear() - 1970);

//         if (dob > today) {
//             alert('Please enter a valid date of birth. Future dates are not allowed.');
//             event.preventDefault(); // Prevent form submission
//             return;
//         }

//         if (age < 10) {
//             alert('Please enter a valid date of birth. You must be at least 10 years old.');
//             event.preventDefault(); // Prevent form submission
//             return;
//         }
//     });
// });
