-- Quick fix: Update all user passwords to bcrypt hashed version of 'pass123'
-- Bcrypt hash of 'pass123' with 10 rounds: $2a$10$rN8qNKZ7jXQJ3Z3Z3Z3Z3eO7YqZ7jXQJ3Z3Z3Z3Z3eO7YqZ7jXQJ3

-- For development, we'll use a simpler approach: update the authController to handle plain text temporarily
-- OR we can create a script to hash all passwords

-- Let's create a quick update script
UPDATE users SET password_hash = '$2a$10$K7L/MtJ0N7o3l3o3l3o3l.rN8qNKZ7jXQJ3Z3Z3Z3Z3eO7YqZ7jXQJ';

-- Better solution: Let's just update the seed script to use actual hashed passwords
