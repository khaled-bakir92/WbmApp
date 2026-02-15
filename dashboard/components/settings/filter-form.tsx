"use client";

import { useEffect, useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  CardDescription,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Loader2, X } from "lucide-react";
import { useFilterConfig } from "@/hooks/use-filter-config";

const filterSchema = z.object({
  max_warmmiete: z.number().min(0),
  min_zimmer: z.number().min(1),
  wbs_required: z.string(),
});

type FilterFormValues = z.infer<typeof filterSchema>;

export function FilterForm() {
  const { query, mutation } = useFilterConfig();
  const [excludedAreas, setExcludedAreas] = useState<string[]>([]);
  const [areaInput, setAreaInput] = useState("");

  const form = useForm<FilterFormValues>({
    resolver: zodResolver(filterSchema),
    defaultValues: {
      max_warmmiete: 1950,
      min_zimmer: 2,
      wbs_required: "any",
    },
  });

  useEffect(() => {
    if (query.data) {
      form.reset({
        max_warmmiete: query.data.max_warmmiete,
        min_zimmer: query.data.min_zimmer,
        wbs_required:
          query.data.wbs_required === true
            ? "yes"
            : query.data.wbs_required === false
              ? "no"
              : "any",
      });
      setExcludedAreas(query.data.excluded_areas);
    }
  }, [query.data, form]);

  const addArea = () => {
    const trimmed = areaInput.trim();
    if (trimmed && !excludedAreas.includes(trimmed)) {
      setExcludedAreas([...excludedAreas, trimmed]);
      setAreaInput("");
    }
  };

  const removeArea = (area: string) => {
    setExcludedAreas(excludedAreas.filter((a) => a !== area));
  };

  const onSubmit = (values: FilterFormValues) => {
    mutation.mutate({
      max_warmmiete: values.max_warmmiete,
      min_zimmer: values.min_zimmer,
      wbs_required:
        values.wbs_required === "yes"
          ? true
          : values.wbs_required === "no"
            ? false
            : null,
      excluded_areas: excludedAreas,
    });
  };

  const is404 = query.isError && query.error?.message?.includes("404");

  if (query.isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Filter Settings</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {Array.from({ length: 3 }).map((_, i) => (
            <Skeleton key={i} className="h-10 w-full" />
          ))}
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Filter Settings</CardTitle>
        <CardDescription>
          {is404
            ? "No filter config found. Fill in the fields to create one."
            : "Criteria for filtering apartment listings"}
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="max_warmmiete">Max Warmmiete (&euro;)</Label>
              <Input
                {...form.register("max_warmmiete", { valueAsNumber: true })}
                type="number"
                min={0}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="min_zimmer">Min Zimmer</Label>
              <Input
                {...form.register("min_zimmer", { valueAsNumber: true })}
                type="number"
                min={1}
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label>WBS Required</Label>
            <div className="flex gap-3">
              {[
                { value: "any", label: "Any" },
                { value: "yes", label: "Yes" },
                { value: "no", label: "No" },
              ].map((opt) => (
                <label key={opt.value} className="flex items-center gap-1.5">
                  <input
                    type="radio"
                    value={opt.value}
                    {...form.register("wbs_required")}
                    className="accent-primary"
                  />
                  <span className="text-sm">{opt.label}</span>
                </label>
              ))}
            </div>
          </div>

          <div className="space-y-2">
            <Label>Excluded Areas</Label>
            <div className="flex gap-2">
              <Input
                value={areaInput}
                onChange={(e) => setAreaInput(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    e.preventDefault();
                    addArea();
                  }
                }}
                placeholder="Add area..."
              />
              <Button type="button" variant="outline" onClick={addArea}>
                Add
              </Button>
            </div>
            {excludedAreas.length > 0 && (
              <div className="flex flex-wrap gap-1.5 mt-2">
                {excludedAreas.map((area) => (
                  <Badge key={area} variant="secondary" className="gap-1">
                    {area}
                    <button type="button" onClick={() => removeArea(area)}>
                      <X className="h-3 w-3" />
                    </button>
                  </Badge>
                ))}
              </div>
            )}
          </div>

          <div className="flex gap-2 pt-2">
            <Button type="submit" disabled={mutation.isPending}>
              {mutation.isPending && (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              )}
              {is404 ? "Create" : "Save"}
            </Button>
            <Button
              type="button"
              variant="outline"
              onClick={() => {
                if (query.data) {
                  form.reset({
                    max_warmmiete: query.data.max_warmmiete,
                    min_zimmer: query.data.min_zimmer,
                    wbs_required:
                      query.data.wbs_required === true
                        ? "yes"
                        : query.data.wbs_required === false
                          ? "no"
                          : "any",
                  });
                  setExcludedAreas(query.data.excluded_areas);
                }
              }}
            >
              Reset
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
