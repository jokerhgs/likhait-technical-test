import React, { useState } from "react";
import { TextField, Button } from "../vibes";

interface CategoryFormProps {
  onSubmit: (categoryName: string) => Promise<void>;
  onCancel?: () => void;
  existingCategories?: string[];
}

export function CategoryForm({
  onSubmit,
  onCancel,
  existingCategories = [],
}: CategoryFormProps) {
  const [name, setName] = useState("");
  const [error, setError] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  const validate = (val: string): string | null => {
    const trimmed = val.trim();
    if (!trimmed) {
      return "Category name is required";
    }
    if (trimmed.length < 2) {
      return "Category name must be at least 2 characters";
    }
    if (trimmed.length > 50) {
      return "Category name cannot exceed 50 characters";
    }
    const isDuplicate = existingCategories.some(
      (cat) => cat.toLowerCase() === trimmed.toLowerCase(),
    );
    if (isDuplicate) {
      return "Category already exists";
    }
    return null;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const validationError = validate(name);
    if (validationError) {
      setError(validationError);
      return;
    }

    try {
      setIsSubmitting(true);
      setError("");
      await onSubmit(name.trim());
      setName("");
    } catch (err: any) {
      setError(err.message || "Failed to create category");
    } finally {
      setIsSubmitting(false);
    }
  };

  const formStyle: React.CSSProperties = {
    display: "flex",
    flexDirection: "column",
    gap: "1rem",
  };

  const buttonGroupStyle: React.CSSProperties = {
    display: "flex",
    gap: "0.5rem",
    marginTop: "0.5rem",
  };

  return (
    <form onSubmit={handleSubmit} style={formStyle}>
      <TextField
        label="Category Name"
        type="text"
        placeholder="Enter new category name (e.g. Subscriptions)"
        value={name}
        onChange={(e) => {
          setName(e.target.value);
          if (error) setError("");
        }}
        error={error}
        fullWidth
        required
      />

      <div style={buttonGroupStyle}>
        <Button
          type="submit"
          variant="primary"
          disabled={isSubmitting}
          fullWidth
        >
          {isSubmitting ? "Saving..." : "Add Category"}
        </Button>
        {onCancel && (
          <Button
            type="button"
            variant="secondary"
            onClick={onCancel}
            disabled={isSubmitting}
          >
            Cancel
          </Button>
        )}
      </div>
    </form>
  );
}
