import z from "zod";

export const signupSchema = z.object({
  email: z.string().trim().email("Invalid email address"),
  password: z
    .string()
    .min(6, "Password must be at least 6 characters long")
    .regex(
      /^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z\d])[^\s]{6,}$/,
      "Password must contain at least one letter, one number, and one symbol",
    ),
});
