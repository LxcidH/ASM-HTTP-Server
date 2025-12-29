document.addEventListener("DOMContentLoaded", () => {
    const statsContainer = document.querySelector('.stats');
    const message = "> JAVASCRIPT: SYSTEM INTEGRATED";
    
    // Create the new line element
    const newLine = document.createElement('p');
    newLine.style.textShadow = "0 0 5px #fff"; // Add a little glow
    statsContainer.appendChild(newLine);

    // Typing effect logic
    let i = 0;
    function typeWriter() {
        if (i < message.length) {
            newLine.textContent += message.charAt(i);
            i++;
            setTimeout(typeWriter, 50); // Speed of typing (ms)
        } else {
            // Blink effect at the end
            newLine.innerHTML += '<span class="blink">_</span>';
            setInterval(() => {
                const cursor = document.querySelector('.blink');
                cursor.style.visibility = (cursor.style.visibility === 'hidden' ? '' : 'hidden');
            }, 500);
        }
    }

    // Start typing after a short delay
    setTimeout(typeWriter, 500);
});
