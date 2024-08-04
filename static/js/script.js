document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('dataForm');

    form.addEventListener('submit', (event) => {
        const phone = document.getElementById('phone').value;
        const phonePattern = /^0[0-9]{10}$/;

        if (!phonePattern.test(phone)) {
            alert('Please enter a valid 10-digit phone number.');
            event.preventDefault(); // Prevent form submission
        }

        const agree = document.getElementById('agree').checked;
        if (!agree) {
            alert('You must agree to the terms and conditions.');
            event.preventDefault(); // Prevent form submission
        }
    });
});
